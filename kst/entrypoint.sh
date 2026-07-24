#!/bin/bash
set -uo pipefail

# Env:
# KST_PROFILE            : Path to the execution profile.
# KST_INSTANT            : Immediate test flag; if present, runs as an immediate test.
# LOCAL_KST_PATH         : Path to the 'tests' directory (required); fails unless passed at runtime or set via KST_PROFILE.
# LOCAL_KST_COMPILED_PATH: Path to the 'compiled' directory.
# LOCAL_KST_FORMATS_PATH : Path to the 'formats' directory.
# LOCAL_KST_SPEC_PATH    : Path to the 'spec' directory.
# LOCAL_KST_SRC_PATH     : Path to the 'src' directory.
# LOCAL_KST_CONFIG_PATH  : Path to the Kaitai Struct Tests configuration.
# LOCAL_KST_TEST_OUT_PATH: Path to the 'test_out' directory.

# Constats:
KST_PROFILE_NAME=.kstprofile
KST_TMP_KST_PATH=/.tests
KST_MOUNT_PATH=/workspace
KST_KST_REPO_PATH=/ks/tests

function validate_exec_context () {
    if [ ! -v KST_KST_REPO_PATH ]; then
        echo "Not exists variable: KST_KST_REPO_PATH"
        exit 128
    elif [ ! -e "$KST_KST_REPO_PATH" ]; then
        echo "Not exists path: KST_KST_REPO_PATH=\"$KST_KST_REPO_PATH\"."
        exit 129
    fi

    if [ ! -v KST_MOUNT_PATH ]; then
        echo "Not exists variable: KST_MOUNT_PATH"
        exit 130
    elif [ ! -e "$KST_MOUNT_PATH" ]; then
        echo "Not exists path: KST_MOUNT_PATH\"$KST_MOUNT_PATH\"."
        exit 131
    fi

    if [ -v LOCAL_KST_PATH ] && [ ! -e "$LOCAL_KST_PATH" ]; then
        echo "Not exists path: LOCAL_KST_PATH=\"$LOCAL_KST_PATH\""
        exit 132
    fi
}

function setup_kst () {
    if [ -v KST_INSTANT ]; then
        create_tmp_kst
    elif [ -v LOCAL_KST_PATH ]; then
        KST_BASE_PATH=$(readlink -f "$LOCAL_KST_PATH")
        KST_FORMATS_PATH=$(readlink -f "${LOCAL_KST_FORMATS_PATH:-$KST_BASE_PATH/formats}")
        KST_COMPILED_PATH=$(readlink -fm "${LOCAL_KST_COMPILED_PATH:-$KST_BASE_PATH/compiled}")
        KST_SPEC_PATH=$(readlink -f "${LOCAL_KST_SPEC_PATH:-$KST_BASE_PATH/spec}")
        KST_SRC_PATH=$(readlink -f "${LOCAL_KST_SRC_PATH:-$KST_BASE_PATH/src}")
        KST_CONFIG_PATH=$(readlink -fm "${LOCAL_KST_CONFIG_PATH:-$KST_BASE_PATH/config}")
        KST_TEST_OUT_PATH=$(readlink -fm "${LOCAL_KST_TEST_OUT_PATH:-$KST_BASE_PATH/test_out}")
    else
        KST_IS_INVALID=1
        return 0
    fi

    KST_IS_INVALID=$(
        for p in "$KST_BASE_PATH" "$KST_FORMATS_PATH" "$KST_SPEC_PATH" "$KST_SRC_PATH"; do
            [ ! -e "$p" ] && echo "$p"
        done
        true
    )

    if [ -n "$KST_IS_INVALID" ]; then
        KST_IS_INVALID=1
        return 0
    else
        KST_IS_INVALID=0
    fi

    if [ ! -f "$KST_CONFIG_PATH" ]; then
        create_tmp_config
    fi

    if [ ! -L "$KST_KST_REPO_PATH"/formats ]; then
        ln -s "$KST_FORMATS_PATH" "$KST_KST_REPO_PATH"/formats
    fi

    if [ ! -L "$KST_KST_REPO_PATH"/spec ]; then
        ln -s "$KST_SPEC_PATH" "$KST_KST_REPO_PATH"/spec
    fi

    if [ ! -L "$KST_KST_REPO_PATH"/src ]; then
        ln -s "$KST_SRC_PATH" "$KST_KST_REPO_PATH"/src
    fi

    if [ ! -L "$KST_KST_REPO_PATH"/config ]; then
        ln -s "$KST_CONFIG_PATH" "$KST_KST_REPO_PATH"/config
    fi

    return 0
}

function create_tmp_config () {
    if [ ! -d "$KST_TMP_KST_PATH" ]; then
        mkdir "$KST_TMP_KST_PATH"
    fi
    KST_CONFIG_PATH="$KST_TMP_KST_PATH"/config

cat << EOF > $KST_CONFIG_PATH
COMPILER_DIR=../compiler
FORMATS_KSY_DIR=$KST_FORMATS_PATH
FORMATS_COMPILED_DIR=$KST_COMPILED_PATH
FORMATS_REPO_DIR=../formats

CSHARP_RUNTIME_DIR=../runtime/csharp
JAVA_RUNTIME_DIR=../runtime/java
JAVA_TESTNG_JAR=\$HOME/.m2/repository/org/testng/testng/6.9.10/testng-6.9.10.jar:\$HOME/.m2/repository/com/beust/jcommander/1.48/jcommander-1.48.jar
JAVASCRIPT_RUNTIME_DIR=../runtime/javascript
JAVASCRIPT_MODULES_DIR=node_modules
JULIA_RUNTIME_DIR=../runtime/julia
LUA_RUNTIME_DIR=../runtime/lua
NIM_RUNTIME_DIR=../runtime/nim
NIM_TESTIFY_DIR=spec.bak/nim/testify
PERL_RUNTIME_DIR=../runtime/perl/lib
PHP_RUNTIME_DIR=../runtime/php
PYTHON_RUNTIME_DIR=../runtime/python
RUBY_RUNTIME_DIR=../runtime/ruby/lib
RUST_RUNTIME_DIR=../runtime/rust

TEST_OUT_DIR=$KST_TEST_OUT_PATH

ENABLE_WRITE=1

cd $KST_KST_REPO_PATH
EOF
}

function create_tmp_kst() {
    # /ks/tests/formats  : LOCAL_KST_PATH
    # /ks/tests/compiled : LOCAL_KST_COMPILED_PATH | /.tests/compiled
    # /ks/tests/spec     : /.tests/spec
    # /ks/tests/src      : LOCAL_KST_PATH
    # /ks/tests/test_out : LOCAL_KST_TEST_OUT_PATH | /.tests/test_out

    KST_BASE_PATH=$(readlink -f "$LOCAL_KST_PATH")
    KST_FORMATS_PATH=$(readlink -f "${LOCAL_KST_FORMATS_PATH:-$KST_BASE_PATH}")
    KST_COMPILED_PATH=$(readlink -fm "${LOCAL_KST_COMPILED_PATH:-$KST_TMP_KST_PATH/compiled}")
    KST_SPEC_PATH=$(readlink -fm "${LOCAL_KST_SPEC_PATH:-$KST_TMP_KST_PATH/spec}")
    KST_SRC_PATH=$(readlink -f "${LOCAL_KST_SRC_PATH:-$KST_BASE_PATH}")
    KST_CONFIG_PATH=$(readlink -fm "${LOCAL_KST_CONFIG_PATH:-$KST_BASE_PATH/config}")
    KST_TEST_OUT_PATH=$(readlink -fm "${LOCAL_KST_TEST_OUT_PATH:-$KST_TMP_KST_PATH/test_out}")

    if [ ! -d "$KST_TMP_KST_PATH" ]; then
        mkdir "$KST_TMP_KST_PATH"
    fi
    if [ ! -d "$KST_SPEC_PATH/ks" ]; then
        mkdir -p "$KST_SPEC_PATH/ks"
    fi
    if [ ! -v LOCAL_KST_SPEC_PATH ] || [ ! "$LOCAL_KST_SPEC_PATH" -eq "$KST_SPEC_PATH" ]; then
        cp -s "$KST_BASE_PATH"/*.kst "$KST_SPEC_PATH"/ks
    fi

    return 0
}

function export_kst_env() {
    export KST_BASE_PATH
    export KST_FORMATS_PATH
    export KST_SPEC_PATH
    export KST_SRC_PATH
    export KST_CONFIG_PATH
    export KST_IS_INVALID
}

function setup_kst_python() {
    if [ "$KST_IS_INVALID" -eq 1 ]; then
        return 0
    fi

    if [ ! -f "$KST_SPEC_PATH"/python/specwrite/common_spec.py ]; then
        if [ ! -d "$KST_SPEC_PATH"/python/specwrite ]; then
            mkdir -p "$KST_SPEC_PATH"/python/specwrite
        fi
        cp -p "$KST_KST_REPO_PATH"/spec.bak/python/specwrite/common_spec.py "$KST_SPEC_PATH"/python/specwrite/
    fi

    return 0
}

cd "$KST_MOUNT_PATH" || exit

if [ -v KST_PROFILE ] && [ -e "$KST_PROFILE" ] && [ ! -v KST_INSTANT ]; then
    # kstProfile=${KST_PROFILE:-/"$KST_PROFILE_NAME"}
    # shellcheck disable=SC1090
    . "$KST_PROFILE"
fi

validate_exec_context

if [ -v LOCAL_KST_PATH ]; then
    setup_kst
    setup_kst_python
    export_kst_env
else
    KST_IS_INVALID=1
fi

cmd=""
for arg in "$@"; do
    if [[ ! "$arg" =~ ^[[:space:]]*(sh|bash|-).*$ ]]; then
        cmd="$arg"
        break
    fi
done
if [ "$KST_IS_INVALID" -eq 0 ] && [ -n "$cmd" ] && [[ ! "$cmd" =~ ^[[:space:]]*(ksc|ksv|ksdump|ipython).* ]]; then
    cd "$KST_KST_REPO_PATH" || exit
elif [ -v LOCAL_KST_PATH ]; then
    cd "$KST_BASE_PATH" || exit
fi 

exec "$@"
