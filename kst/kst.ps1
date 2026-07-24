#!/usr/bin/env pwsh

# ==============================================================================
# Copyright (c) 2026 KITA Munemitsu
# This script is released under the GNU General Public License v3.0.
# SPDX-License-Identifier: GPL-3.0-or-later
# ==============================================================================

<#
.SYNOPSIS
    Command to use the Dockerized Kaitai Struct Tests as a tool.
.DESCRIPTION
    If the docker image does not exist, it is built automatically.
    A KST directory is a directory that serves as an execution unit for Kaitai Struct Tests.

    Commands:
        build-formats <langs>   : Compile .ksy files in `formats` for the specified `langs`.
        build-tests <langs>     : Generate tests from .kst files in `spec/ks` for the specified `langs`.
        run-test                : Run tests for Python.
        run-ci                  : Run tests and generate test reports for Python.
        build                   : Compile .ksy files in `formats` and generate tests from .kst files in `spec/ks`.
        test                    : Compile .ksy files, generate tests from .kst files, and run tests for Python.
        ci                      : Compile .ksy files, generate tests from .kst files, and run tests then, generate test reports for Python.
        itest                   : Immediately run tests for Python using the .ksy files, .kst files, and test binaries located in the working directory.
        ici                     : Immediately run tests for Python using the .ksy files, .kst files, and test binaries located in the working directory then, output test reports to `test_out`.
        create <dir> [test_kst] : Generate a local KST directory.
        push <kst_dir>          : Copies `compiled`, `formats`, `spec`, and `src` from the current KST directory to the specified KST directory.
        pull <kst_dir>          : Copies `compiled`, `formats`, `spec`, and `src` from the specified KST directory to the current KST directory.
        push-test <kst_dir>     : Copies tests from the current KST directory to the test KST directory (`.tests`) of the specified KST directory.
        pull-test <kst_dir>     : Copies tests from the specified KST directory to the test KST directory (`.tests`) of the current KST directory.
        test-merge              : Copies tests from the current KST directory to the test KST directory (`.tests`) and runs tests.
        test-ci                 : Copies tests from the current KST directory to the test KST directory (`.tests`) and runs tests then, generate test reports.
        copy <src> <dest>       : Copies `compiled`, `formats`, `spec`, and `src` from the source KST directory to the destination KST directory.
        create-command [...]    : Outputs `kst.ps1` with fixed settings to the specified directory.
        about                   : Display information about Kaitai Struct used within the Docker image.
        *                       : Executes the specified arguments as-is within the container.

    Environmental variables:
        KST_DOCKER_MOUNT_PATH   : Path of the directory to mount to Docker.
        KST_DOCKERFILE_PATH     : The path to the directory containing the Dockerfile.
        KST_DOCKER_IMAGE_NAME   : Docker image name.
        KST_PROFILE             : Relative path from the mount point to the appropriate KST (`kst_profile`) targeted for test execution.
        KST_SINGLE_SOURCE       : Relative path from the mount point to the src dir. This is effective only for kst generation and does not affect test execution.
.EXAMPLE
    PS> ./kst.ps1 build-formats python

    Compile .ksy files in `formats` for Python.
    The code is output to `compiled/python/testformats` and `compiled/python/testwrite`.
.EXAMPLE
    PS> ./kst.ps1 build-tests python python-write

    Generate tests from .kst fiels in `spec/ks` for Python.
    Test code is output to `spec/python/spec` and `spec/python/specwrite`.
    The test code references `compiled/python/testformats` and `compiled/python/testwrite`.
.EXAMPLE
    PS> ./kst.ps1 run-test

    Run tests for Python.
    Output the test results to the console.
.EXAMPLE
    PS> ./kst.ps1 test

    Compile .ksy files, generate tests from .kst files, and run tests for Python.
    Output the test results to the console.
.EXAMPLE
    PS> ./kst.ps1 ci

    Compile .ksy files, generate tests from .kst files, and run tests then, generate test reports.
    Output the test report to `tests/test_out`.
.EXAMPLE
    PS> ./kst.ps1 create dev

    Generate the local KST directory, related files, and the script, using the working directory at the time of script execution as the base.
.EXAMPLE
    PS> ./kst.ps1 create dev tests

    Create a `dev` KST directory and copy the test code from the `tests` KST directory to the `dev` test KST (`dev/.tests`).
.EXAMPLE
    PS> ./kst.ps1 push ../tests

    Copy the set of components from the `dev` KST directory to the KST directory specified by the relative path `../tests`.
.EXAMPLE
    PS> ./kst.ps1 pull ../tests

    Copy the set of KST directory components specified by the relative path `../tests` to the current KST directory (`dev`).
.EXAMPLE
    PS> ./kst.ps1 push-test ../tests
    
    Copy the set of components from the current KST directory to the test KST (`.tests`) located in the KST directory specified by the relative path `../tests`.
.EXAMPLE
    PS> ./kst.ps1 pull-test ../tests

    Copy the set of components within the KST directory specified by the relative path `../tests` to the test KST directory (`.tests`) of the current KST directory.
.EXAMPLE
    PS> ./kst.ps1 test-merge

    Copy the test code from the current KST directory (`dev`) to the test KST directory (`dev/.tests`) and execute the tests.
.EXAMPLE
    PS> ./kst/kst.ps1 create-command

    Assume you have a directory where the repository has been cloned to `devksy/kst`.
    This generates a `kst.ps1` file in `devksy` that hardcodes parameters related to KST operations as environment variables.

    The invocation signature is as follows:

    create-command [target_dir] [mount_path] [image_name] [dockerfile_dir]
    
    params:
      target_dir     : The directory where `kst.ps1` will be generated
      mount_path     : The path of the directory to mount to the KST Docker container
      image_name     : The KST Docker image name
      dockerfile_dir : The path of the directory containing the KST Dockerfile
    
    If `dockerfile_dir` is omitted, the Dockerfile is assumed to be in the same directory as the called `kst.ps1`.
    If `image_name` is omitted, `kaitai-struct-test-tool` is used as the image name.
    If `mount_path` is omitted, the current working directory is assumed to be the mount path.
    If `target_dir` is omitted, the current working directory is used as the output location for `kst.ps1`.
.EXAMPLE
    PS> ./kst/kst.ps1 create-command @{SingleSource='src'}

    It generates a `kst.ps1` script that specifies the `src` directory within the working directory as a single binary source when creating the KST directory.
    All KST directories generated by the script use `src` as the binary source.
    The same applies to the test KSTs located under the KST directories.
    Specify SingleSource as a relative path from the Docker mount path.
    The specified path must be valid at the time of the Docker mount.
    The `create-command` accepts a hash table containing the parameters.
    The mapping between parameters and keys is as follows:

    keys:
      TargetDir       : target_dir
      DockerMountPath : mount_path
      DockerImageName : image_name
      DockerfilePath  : dockerfile_dir
      SingleSource    : [none]
.EXAMPLE
    PS> ./kst.ps1 copy src dest

    Copy the `compiled`, `formats`, `spec` and `src` directories from the KST directory specified by `src` to the KST directory specified by `dest`.
    Overwrite the files if they already exist.
#>

# Mount path in Docker (source)
$mountPath = $env:KST_DOCKER_MOUNT_PATH ?? '.'

# The relative path from this script to the directory containing the Dockerfile.
$dockerfilePath = $env:KST_DOCKERFILE_PATH ?? '.'

# Docker image name
$imageName = $env:KST_DOCKER_IMAGE_NAME ?? 'kaitai-struct-test-tool'

# KST profile
$kstProfile = $env:KST_PROFILE # ?? '/.kstprofile'

# Relative path from the mount point to the src dir.
# If a valid value is set for this, all generated KSTs will use it as the source.
$kstSingleSource = $env:KST_SINGLE_SOURCE

# Constants
Set-Variable -Name 'KST_PROFILE_NAME' -Value '.kstprofile' -Option Constant
Set-Variable -Name 'KST_SCRIPT_NAME' -Value 'kst.ps1' -Option Constant
Set-Variable -NAME 'ABOUT_VERSION' -Value '0.0.1' -Option Constant
Set-Variable -NAME 'ABOUT_REPOSITORY' -Value 'https://github.com/kmu2030/kaitai-struct-test-tool' -Option Constant

function Show-Usage {
    Write-Host "Usage: ./kst.ps1 <command> [options]" -ForegroundColor Yellow
    Write-Host "`nCommands:"
    Write-Host "  build-formats <langs>   : Compile ksy files in ``formats`` for the specified ``langs``."
    Write-Host "  build-tests <langs>     : Generate tests from .kst files in ``spec/ks`` for the specified ``langs``."
    Write-Host "  build                   : Compile .ksy files in ``formats`` and generate tests from .kst files in ``spec/ks``."
    Write-Host "  run-test                : Run tests for Python."
    Write-Host "  run-ci                  : Generate test reports for Python."
    Write-Host "  test                    : Compile ksy files, generate tests from kst files, and run tests for Python."
    Write-Host "  ci                      : Compile Ksy files, generate tests from Kst files, and generate a test report for Python."
    Write-Host "  itest                   : Immediately run tests for Python using the .ksy files, .kst files, and test binaries located in the working directory."
    Write-Host "  ici                     : Immediately run tests for Python using the .ksy files, .kst files, and test binaries located in the working directory then, output test reports to ``test_out``."
    Write-Host "  create <dir> [test_kst] : Generates a local KST environment."
    Write-Host "  push <dest>             : Copies ``compiled``, ``formats``, ``spec``, and ``src`` from the current KST directory to the specified KST directory."
    Write-Host "  pull <src>              : Copies ``compiled``, ``formats``, ``spec``, and ``src`` from the specified KST directory to the current KST directory."
    Write-Host "  push-test <dest>        : Copies tests from the current KST directory to the test KST directory (``.tests``) of the specified KST directory."
    Write-Host "  pull-test <src>         : Copies tests from the specified KST directory to the test KST directory (``.tests``) of the current KST directory."
    Write-Host "  test-merge              : Copies tests from the current KST directory to the test KST directory (``.tests``) and runs tests for Python."
    Write-Host "  test-ci                 : Copies tests from the current KST directory to the test KST directory (`.tests`) and runs tests then, generate test reports for Python."
    Write-Host "  copy <src> <dest>       : Copies ``compiled``, ``formats``, ``spec``, and ``src`` from the source KST directory to the destination KST directory."
    Write-Host "  create-command [...]    : Outputs ``$KST_SCRIPT_NAME` with fixed settings to the specified directory."
    Write-Host "  about                   : Display information about Kaitai Struct used within the Docker image."
    Write-Host "  *                       : Executes the specified arguments as-is within the container."

    Write-Host "`nEnvironmental Variables:"
    Write-Host "  KST_DOCKER_MOUNT_PATH   : Path of the directory to mount to Docker."
    Write-Host "  KST_DOCKERFILE_PATH     : The path to the directory containing the Dockerfile."
    Write-Host "  KST_DOCKER_IMAGE_NAME   : Docker image name."
    Write-Host "  KST_PROFILE             : Relative path from the mount point to the appropriate KST (``$KST_PROFILE_NAME``) targeted for test execution."
    Write-Host "  KST_SINGLE_SOURCE       : Relative path from the mount point to the src dir. This is effective only for kst generation and does not affect test execution."
}

function New-ProjectKstCommand {
    param(
        [string]$TargetDir = '.',
        [string]$DockerfilePath = '.',
        [string]$DockerMountPath = '.',
        [string]$DockerImageName = 'kaitai-struct-test-tool',
        [string]$SingleSource = $null
    )

    $cc = Get-CliContext

    $absCliDir = $cc.AbsCliDir
    $absDockerMountDir, $_ = Resolve-AsCliContexAbsPath `
        -Path $DockerMountPath `
        -CliContext $cc `
        -Contexts @([PathContext]::Pwd, [PathContext]::Cli, [PathContext]::Individual)

    $absDockerfileDir, $_ = Resolve-AsCliContexAbsPath `
        -Path $DockerfilePath `
        -CliContext $cc `
        -Contexts @([PathContext]::Cli, [PathContext]::Pwd, [PathContext]::Individual)

    if (-not [string]::IsNullOrEmpty($SingleSource)) {
        $absSingleSource, $_ = Resolve-AsCliContexAbsPath `
            -Path $SingleSource `
            -CliContext $cc `
            -Contexts @([PathContext]::Pwd, [PathContext]::Individual)
    }

    $absTargetDir, $_ = Resolve-AsCliContexAbsPath `
        -Path $TargetDir `
        -CliContext $cc `
        -Contexts @([PathContext]::Pwd, [PathContext]::Individual)

    if ($null -in @($absDockerMountDir, $absDockerfileDir, $absTargetDir)) {
        Write-Error "The paths is illegal: DockerMountDir='$absDockerMountDir', Dockerfiledir='$absDockerfileDir', KstDir='$absTargetDir'"
        return $false
    }

    $outScriptPath = "$absTargetDir/$KST_SCRIPT_NAME"

    if (Test-Path -Path $outScriptPath) {
        Write-Error "The path exists: '$outScriptPath'"
        return $false
    }

    $relCliToDockerMount = [System.IO.Path]::GetRelativePath($absCliDir, $absDockerMountDir).Replace('\', '/')
    $relCliToDockerfile = [System.IO.Path]::GetRelativePath($absCliDir, $absDockerfileDir).Replace('\', '/')
    $relTargetToCli = [System.IO.Path]::GetRelativePath($absTargetDir, $absCliDir).Replace('\', '/')
    if ($null -ne $absSingleSource) {
        $relDockerMountToSingleSource = [System.IO.Path]::GetRelativePath($absDockerMountDir, $absSingleSource).Replace('\', '/')
    }

    $kstCmd = @"
#!/usr/bin/env pwsh
pwsh -Command @"
```$env:KST_DOCKER_MOUNT_PATH='$relCliToDockerMount';
```$env:KST_DOCKERFILE_PATH='$relCliToDockerfile';
```$env:KST_DOCKER_IMAGE_NAME='$DockerImageName';
$($null -ne $absSingleSource ? "```$env:KST_SINGLE_SOURCE='$relDockerMountToSingleSource';" : '')
& '`$(Split-Path -Parent `$MyInvocation.MyCommand.Definition)/$relTargetToCli/$KST_SCRIPT_NAME' `$args
`"@
"@

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($outScriptPath, $kstCmd, $encoding)

    return $true
}

function New-Kst {
    param(
        [string]$TargetDir,
        [string]$MountPath,
        [hashtable]$Context = $null
    )

    $cc = Get-CliContext

    $absTargetDir, $_ = Resolve-AsCliContexAbsPath `
        -Path $TargetDir `
        -CliContext $cc `
        -Contexts @([PathContext]::Pwd, [PathContext]::Individual) `
        -Virtual $true

    $absMountDir, $_ = Resolve-AsCliContexAbsPath `
        -Path $MountPath `
        -CliContext $cc `
        -Contexts @([PathContext]::Cli, [PathContext]::Individual, [PathContext]::Pwd) `
        -Virtual $false

    $kst = New-KstContext `
        -AbsMountDir $absMountDir `
        -AbsKstDir $absTargetDir

    $relMountToKst = $kst.RelMountToKst
    $relCliToMount = $kst.RelCliToMount
    $relKstToCli = $kst.RelKstToCli

    $encoding = [System.Text.UTF8Encoding]::new($false)

    New-Item -ItemType Directory -Force -Path "$absTargetDir/compiled" > $null
    New-Item -ItemType Directory -Force -Path "$absTargetDir/formats" > $null
    New-Item -ItemType Directory -Force -Path "$absTargetDir/spec/ks" > $null
    New-Item -ItemType Directory -Force -Path "$absTargetDir/src" > $null

    $configParam = @{
        FormatsKsyDir      = $Context.Config.FormatsKsyDir `
            ? "`"$($Context.Config.FormatsKsyDir)@`"" `
            : "'/workspace/$relMountToKst/formats'"
        FormatsCompiledDir = $Context.Config.FormatsCompiledDir `
            ? "`"$($Context.Config.FormatsCompiledDir)@`"" `
            : "'/workspace/$relMountToKst/compiled'"
        TestOut            = $Context.Config.TestOut `
            ? "`"$($Context.Config.TestOut)@`"" `
            :"'/workspace/$relMountToKst/test_out'"
    }

    $config = @"
COMPILER_DIR=../compiler
FORMATS_KSY_DIR=$($configParam.FormatsKsyDir)
FORMATS_COMPILED_DIR=$($configParam.FormatsCompiledDir)
FORMATS_REPO_DIR=../formats

CSHARP_RUNTIME_DIR=../runtime/csharp
JAVA_RUNTIME_DIR=../runtime/java
JAVA_TESTNG_JAR=`$HOME/.m2/repository/org/testng/testng/6.9.10/testng-6.9.10.jar:`$HOME/.m2/repository/com/beust/jcommander/1.48/jcommander-1.48.jar
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

TEST_OUT_DIR=$($configParam.TestOut)

# ENABLE_WRITE=1

cd /ks/tests
"@ -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText("$absTargetDir/config", $config, $encoding)

    $kstProfileParam = @{
        LocalKstPath        = $Context.Profile.LocalKstPath `
            ? "`"$($Context.Profile.LocalKstPath)@`"" `
            : "'$relMountToKst'"
        LocalKstFormatsPath = $Context.Profile.LocalKstFormatsPath `
            ? "`"$($Context.Profile.LocalKstFormatsPath)`"" `
            : '"$LOCAL_KST_PATH"/formats'
        LocalKstSpecPath    = $Context.Profile.LocalSpecPath `
            ? "`"$($Context.Profile.LocalKstSpecPath)`"" `
            : '"$LOCAL_KST_PATH"/spec'
        LocalKstSrcPath     = $Context.Profile.LocalKstSrcPath `
            ? "`"$($Context.Profile.LocalKstSrcPath)`"" `
            : '"$LOCAL_KST_PATH"/src'
        LocalKstConfigPath  = $Context.Profile.LocalConfigPath `
            ? "`"$($Context.Profile.LocalConfigPath)`"" `
            : '"$LOCAL_KST_PATH"/config'
    }

    $kstProf = @"
LOCAL_KST_PATH=$($kstProfileParam.LocalKstPath)
LOCAL_KST_FORMATS_PATH=$($kstProfileParam.LocalKstFormatsPath)
LOCAL_KST_SPEC_PATH=$($kstProfileParam.LocalKstSpecPath)
LOCAL_KST_SRC_PATH=$($kstProfileParam.LocalKstSrcPath)
LOCAL_KST_CONFIG_PATH=$($kstProfileParam.LocalKstConfigPath)
"@ -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($kst.AbsKstProfile, $kstProf, $encoding)

    $kstScript = @"
#!/usr/bin/env pwsh
pwsh -Command @"
```$env:KST_DOCKER_MOUNT_PATH='$relCliToMount';
```$env:KST_DOCKERFILE_PATH='$env:KST_DOCKERFILE_PATH';
```$env:KST_DOCKER_IMAGE_NAME='$env:KST_DOCKER_IMAGE_NAME';
```$env:KST_PROFILE='$relMountToKst/$KST_PROFILE_NAME';
$($null -ne $env:KST_SINGLE_SOURCE ? "```$env:KST_SINGLE_SOURCE='$env:KST_SINGLE_SOURCE';" : '')
& '`$(Split-Path -Parent `$MyInvocation.MyCommand.Definition)/$relKstToCli/$KST_SCRIPT_NAME' `$args
`"@
"@
    [System.IO.File]::WriteAllText($kst.AbsKstScript, $kstScript, $encoding)

    return $kst
}

function Copy-Kst {
    param(
        [string]$SrcDir,
        [string]$DestDir,
        [bool]$OnlyTest = $false
    )

    if ([string]::IsNullOrEmpty($SrcDir) -or [string]::IsNullOrEmpty($DestDir)) {
        Write-Host $SrcDir
        Write-Error "Source and destination directories must be specified."
        return $false
    }

    $absSrcDir = (-not (Split-Path -Path $SrcDir -IsAbsolute)) `
        ? (Convert-Path (Join-Path $PWD.Path $SrcDir)) `
        : $SrcDir
    $absDestDir = (-not (Split-Path -Path $DestDir -IsAbsolute)) `
        ? (Convert-Path (Join-Path $PWD.Path $DestDir)) `
        : $DestDir

    $targetSubDirs = $OnlyTest ? @("compiled", "spec", "src") : @("compiled", "formats", "spec", "src")

    foreach ($subDir in $targetSubDirs) {
        $sourcePath = Join-Path $absSrcDir $subDir
        if (-not (Test-Path -Path $sourcePath -PathType Container)) {
            Write-Error "Source directory '$sourcePath' does not exist. Aborting copy."
            return $false
        }
        $destPath = Join-Path $absDestDir $subDir
        if (-not (Test-Path -Path $destPath -PathType Container)) {
            Write-Error "Destination directory '$destPath' does not exist. Aborting copy."
            return $false
        }
    }

    foreach ($subDir in $targetSubDirs) {
        $sourcePath = Join-Path $absSrcDir $subDir
        $destinationPath = Join-Path $absDestDir $subDir

        Get-ChildItem -Path $sourcePath -Recurse | ForEach-Object {
            if ($OnlyTest -and ($_.Extension.ToLower() -in @('.kst', '.ksy'))) { return }

            $relativePath = $_.FullName.Substring($sourcePath.Length).TrimStart('\' , '/')
            if ([string]::IsNullOrEmpty($relativePath)) { return }

            $destItemPath = Join-Path $destinationPath $relativePath

            if ($_.PSIsContainer) {
                if (-not (Test-Path -Path $destItemPath -PathType Container)) {
                    New-Item -ItemType Directory -Force -Path $destItemPath > $null
                }
            }
            else {
                $parentDir = Split-Path -Parent $destItemPath
                if (-not (Test-Path -Path $parentDir -PathType Container)) {
                    New-Item -ItemType Directory -Force -Path $parentDir > $null
                }
                Copy-Item -Path $_.FullName -Destination $destItemPath -Force -ErrorAction Stop
            }
        }
    }

    return $true
}

function New-KstContext {
    param(
        $AbsMountDir,
        $AbsKstDir
    )

    $absCliDir = (Get-ScriptPath).Replace('\', '/')

    $relPwdToCli = [System.IO.Path]::GetRelativePath($PWD.Path, $absCliDir).Replace('\', '/')
    $relCliToPwd = [System.IO.Path]::GetRelativePath($absCliDir, $PWD.Path).Replace('\', '/')
    $relCliToMount = [System.IO.Path]::GetRelativePath($absCliDir, $AbsMountDir).Replace('\', '/')
    $relMountToCli = [System.IO.Path]::GetRelativePath($AbsMountDir, $absCliDir).Replace('\', '/')
    $relPwdToMount = [System.IO.Path]::GetRelativePath($PWD.Path, $AbsMountDir).Replace('\', '/')
    $relMountToPwd = [System.IO.Path]::GetRelativePath($AbsMountDir, $PWD.Path).Replace('\', '/')

    $relCliToKst = [System.IO.Path]::GetRelativePath($absCliDir, $AbsKstDir).Replace('\', '/')
    $relKstToCli = [System.IO.Path]::GetRelativePath($AbsKstDir, $absCliDir).Replace('\', '/')
    $relMountToKst = [System.IO.Path]::GetRelativePath($AbsMountDir, $AbsKstDir).Replace('\', '/')
    $relKstToMount = [System.IO.Path]::GetRelativePath($AbsKstDir, $AbsMountDir).Replace('\', '/')
    $relPwdToKst = [System.IO.Path]::GetRelativePath($PWD.Path, $AbsKstDir).Replace('\', '/')
    $relKstToPwd = [System.IO.Path]::GetRelativePath($AbsKstDir, $PWD.Path).Replace('\', '/')

    $kstProf = "$relMountToKst/$KST_PROFILE_NAME"
    $absKstProf = [System.IO.Path]::GetFullPath($KST_PROFILE_NAME, $AbsKstDir).Replace('\', '/')
    $absKstScript = [System.IO.Path]::GetFullPath($KST_SCRIPT_NAME, $AbsKstDir).Replace('\', '/')

    return @{
        AbsCliDir     = $absCliDir
        AbsScriptDir  = $absCliDir
        AbsMountDir   = $AbsMountDir
        AbsKstDir     = $AbsKstDir

        RelPwdToCli   = $relPwdToCli
        RelCliToPwd   = $relCliToPwd
        RelCliToMount = $relCliToMount
        RelMountToCli = $relMountToCli
        RelPwdToMount = $relPwdToMount
        RelMountToPwd = $relMountToPwd

        RelCliToKst   = $relCliToKst
        RelKstToCli   = $relKstToCli
        RelMountToKst = $relMountToKst
        RelKstToMount = $relKstToMount
        RelPwdToKst   = $relPwdToKst
        RelKstToPwd   = $relKstToPwd
        
        KstProfile    = $kstProf
        AbsKstProfile = $absKstProf
        AbsKstScript  = $absKstScript
    }
}

function Get-CliContext {
    $absScriptDir = (Get-ScriptPath).Replace('\', '/')
    $existsKstProfile = $null -ne $env:KST_PROFILE
    $existsKstDockerMountPath = $null -ne $env:KST_DOCKER_MOUNT_PATH
    $existsKstDockerImageName = $null -ne $env:KST_DOCKER_IMAGE_NAME
    $existsKstDockerfilePath = $null -ne $env:KST_DOCKERFILE_PATH
    $existsKstSingleSource = $null -ne $env:KST_SINGLE_SOURCE

    $dmp = $existsKstDockerMountPath `
        ? $env:KST_DOCKER_MOUNT_PATH `
        : $mountPath

    $absMountDir = $null
    if (Split-Path -Path $dmp -IsAbsolute) {
        $absMountDir = $dmp
    }
    else {
        $absMountDir = [System.IO.Path]::GetFullPath($dmp, $absScriptDir).Replace('\', '/')
        if (-not (Test-Path -Path $absMountDir)) {
            $absMountDir = [System.IO.Path]::GetFullPath($dmp, $PWD.Path).Replace('\', '/')
        }
    }
    if (-not (Test-Path -Path $absMountDir)) { $absMountDir = $null }

    $dfp = $existsKstDockerfilePath `
        ? $env:KST_DOCKERFILE_PATH `
        : $dockerfilePath

    $absDockerfileDir = $null
    if (Split-Path -Path $dfp -IsAbsolute) {
        $absDockerfileDir = $dfp
    }
    else {
        $absDockerfileDir = [System.IO.Path]::GetFullPath($dfp, $absScriptDir).Replace('\', '/')
        if (-not (Test-Path -Path $absMountDir)) {
            $absDockerfileDir = [System.IO.Path]::GetFullPath($dfp, $PWD.Path).Replace('\', '/')
        }
    }
    if (-not (Test-Path -Path $absDockerfileDir)) { $absDockerfileDir = $null }

    $dimg = $existsKstDockerImageName `
        ? $env:KST_DOCKER_IMAGE_NAME `
        : $imageName

    $relPwdToScript = [System.IO.Path]::GetRelativePath($PWD.Path, $absScriptDir).Replace('\', '/')
    $relScriptToPwd = [System.IO.Path]::GetRelativePath($absScriptDir, $PWD.Path).Replace('\', '/')

    if ($null -ne $absMountDir) {
        $relScriptToMount = [System.IO.Path]::GetRelativePath($absScriptDir, $absMountDir).Replace('\', '/')
        $relMountToScript = [System.IO.Path]::GetRelativePath($absMountDir, $absScriptDir).Replace('\', '/')
        $relPwdToMount = [System.IO.Path]::GetRelativePath($PWD.Path, $absMountDir).Replace('\', '/')
        $relMountToPwd = [System.IO.Path]::GetRelativePath($absMountDir, $PWD.Path).Replace('\', '/')
    }

    $kstProf = $existsKstProfile `
        ? $env:KST_PROFILE `
        : $kstProfile

    if ($existsKstProfile) {
        $relMountToKst = Split-Path -Parent $kstProf
        $absKstDir = [System.IO.Path]::GetFullPath($relMountToKst, $absMountDir).Replace('\', '/')
    }
    if ($existsKstProfile -and (Test-Path $absKstDir)) {
        $relScriptToKst = [System.IO.Path]::GetRelativePath($absScriptDir, $absKstDir).Replace('\', '/')
        $relKstToScript = [System.IO.Path]::GetRelativePath($absKstDir, $absScriptDir).Replace('\', '/')
        $relKstToMount = [System.IO.Path]::GetRelativePath($absKstDir, $absMountDir).Replace('\', '/')
        $relPwdToKst = [System.IO.Path]::GetRelativePath($PWD.Path, $absKstDir).Replace('\', '/')
        $relKstToPwd = [System.IO.Path]::GetRelativePath($absKstDir, $PWD.Path).Replace('\', '/')
    }
    else {
        $absKstDir = $null
    }

    $singleSrc = $existsKstSingleSource `
        ? $env:KST_SINGLE_SOURCE `
        : $kstSingleSource

    $localKstPath = $env:LOCAL_KST_PATH

    return @{
        ExistsKstProfile         = $existsKstProfile
        ExistsKstDockerMountPath = $existsKstDockerMountPath
        ExistsKstDockerImageName = $existsKstDockerImageName
        ExistsKstDockerfilePath  = $existsKstDockerfilePath
        ExistsKstSingleSource    = $existsKstSingleSource
        KstProfile               = $kstProf
        AbsDockerfileDir         = $absDockerfileDir
        DockerImageName          = $dimg
        SingleSource             = $singleSrc
        LocalKstPath             = $localKstPath

        AbsCliDir                = $absScriptDir
        AbsScriptDir             = $absScriptDir
        AbsMountDir              = $absMountDir
        AbsKstDir                = $absKstDir
        Pwd                      = $PWD.Path.Replace('\', '/')

        RelMountToKst            = $relMountToKst
        RelKstToMount            = $relKstToMount
        
        RelCliToKst              = $relScriptToKst
        RelKstToCli              = $relKstToScript
        RelMountToCli            = $relMountToScript
        RelCliToMount            = $relScriptToMount

        RelPwdToMount            = $relPwdToMount
        RelMountToPwd            = $relMountToPwd
        RelPwdToKst              = $relPwdToKst
        RelKstToPwd              = $relKstToPwd

        RelPwdToCli              = $relPwdToScript
        RreCliToPwd              = $relScriptToPwd
    }
}

enum PathContext {
    Cli
    DockerMount
    Pwd
    Kst
    ActivePwd
    Individual
}

function Resolve-AsCliContexAbsPath {
    param(
        [string]$Path,
        [hashtable]$CliContext,
        [PathContext[]]$Contexts = @(
            [PathContext]::Cli
            [PathContext]::DockerMount
            [PathContext]::Pwd
            [PathContext]::kst
            [PathContext]::ActivePwd
            [PathContext]::Individual),
        [bool]$Virtual = $false
    )

    if ($null -eq $Path) {
        return $null, $null
    }

    $cPath = $null
    $ctx = $null
    if (Split-Path -Path $Path -IsAbsolute) {
        $ctx = [PathContext]::Individual
        if ([PathContext]::Individual -in $Contexts -and ($Virtual -or (Test-Path -Path $Path))) {
            $cPath = $Path
        }
    }

    if ($null -eq $ctx) {
        foreach ($c in $Contexts) {
            $p = switch ($c) {
                ([PathContext]::Cli) { $CliContext.AbsCliDir; break }
                ([PathContext]::DockerMount) { $CliContext.AbsMountDir; break }
                ([PathContext]::Pwd) { $CliContext.Pwd; break }
                ([PathContext]::Kst) { $CliContext.AbsKstDir; break }
                ([PathContext]::ActivePwd) { $PWD; break }
                Default { $null; break }
            }
            if ($null -eq $p) { continue }

            $cPath = [System.IO.Path]::GetFullPath($Path, $p)
            if ($Virtual -or (Test-Path $cPath)) {
                $ctx = $c
                break
            }
            else {
                $cPath = $null
            }
        }
    }

    if ($null -ne $cPath) {
        $cPath = $cPath.Replace('\', '/')
    }

    return $cPath, $ctx
}

function Resolve-AsCliContexRelPath {
    param(
        [string]$Path,
        [hashtable]$CliContext,
        [PathContext[]]$Contexts = @(
            [PathContext]::Cli
            [PathContext]::DockerMount
            [PathContext]::Pwd
            [PathContext]::kst
            [PathContext]::ActivePwd),
        [bool]$Virtual = $false
    )

    if ($null -eq $Path -or -not ((Split-Path -Path $Path -IsAbsolute) -or ($Virtual -or (Test-Path -Path $Path )))) {
        return $null, $null, $null
    }

    $cPath = $null
    $icPath = $null
    $ctx = $null
    foreach ($c in $Contexts) {
        $p = switch ($c) {
            ([PathContext]::Cli) { $CliContext.AbsCliDir; break }
            ([PathContext]::DockerMount) { $CliContext.AbsMountDir; break }
            ([PathContext]::Pwd) { $CliContext.Pwd; break }
            ([PathCotext]::Kst) { $CliContext.AbsKstDir; break }
            ([PathContext]::ActivePwd) { $PWD.Path; break }
            Default { $null; continue }
        }
        if ($null -eq $p) { continue }

        $cPath = [System.IO.Path]::GetRelativePath($p, $Path)
        $icPath = [System.IO.Path]::GetRelativePath($Path, $p)
        $ctx = $c
        break
    }

    if ($null -ne $cPath) {
        $cPath = $cPath.Replace('\', '/')
    }

    return $cPath, $icPath, $ctx
}

# https://gist.github.com/glombard/1ae65c7c6dfd0a19848c
function Get-ScriptPath {
    $scriptDir = Get-Variable PSScriptRoot -ErrorAction SilentlyContinue | ForEach-Object { $_.Value }
    if (!$scriptDir) {
        if ($MyInvocation.MyCommand.Path) {
            $scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
        }
    }
    if (!$scriptDir) {
        if ($ExecutionContext.SessionState.Module.Path) {
            $scriptDir = Split-Path (Split-Path $ExecutionContext.SessionState.Module.Path)
        }
    }
    if (!$scriptDir) {
        $scriptDir = $PWD
    }
    return $scriptDir
}

function Invoke-Docker {
    param(
        [string[]]$Commands,
        [string[]]$Envs
    )

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "Docker is either not installed or not in your PATH."
        exit 1
    }

    docker info > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "The Docker daemon is not running. Please start Docker Desktop or a similar application."
        exit 1
    }

    $cc = Get-CliContext

    $imageExists = docker images -q $cc.DockerImageName
    if (-not $imageExists) {
        Write-Host "Docker image '$($cc.DockerImageName)' not found. Starting build..." -ForegroundColor Cyan
     
        if ($null -eq $cc.AbsDockerfileDir) {
            Write-Error "Build error: '$($cc.AbsDockerfileDir)' not found."
            exit 1
        }
    
        Push-Location $cc.AbsDockerfileDir
        try {
            docker build --no-cache -t $cc.DockerImageName .
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to build the Docker image."
                exit $LASTEXITCODE
            }
        }
        finally {
            Pop-Location
        }
    
        Write-Host "The Docker image build has completed.`n" -ForegroundColor Green
    }

    if ($null -eq $cc.AbsMountDir) {
        Write-Error "Failed to resolve mount path."
        exit 1
    }

    $dockerEnvs = @(
    ) + $Envs | ForEach-Object { @('-e', $_) }
    $dockerArgs = @('run', '-it', '--rm'
        '--mount', "type=bind,source=$($cc.AbsMountDir),target=/workspace"
        ([string]::IsNullOrEmpty($cc.KstProfile) ? @() : @('-e', "KST_PROFILE=$($cc.KstProfile)"))
        $dockerEnvs
        "$($cc.DockerImageName)"
        ($Commands.Count -gt 0 ? @('sh', '-c', "$($Commands -join " && ")") : @())
        )

    docker @dockerArgs
}

$execCmds = @()
$execEnvs = @()

if ($args.Count -gt 0) {
    $cmdType = $args[0]
    $remainingArgs = $args[1..($args.Count - 1)] -join " "
    $suffix = if ($remainingArgs) { " $remainingArgs" } else { "" }

    switch ($cmdType) {
        "build-formats" {
            $execCmds = @("./build-formats$suffix")
            break
        }
        "build-tests" {
            $execCmds = @("./build-tests$suffix")
            break
        }
        "run-test" {
            $execCmds = @("./run-python")
            break
        }
        "run-ci" {
            $execCmds = @("./ci-python")
            break
        }
        "build" {
            $execCmds = @(
                "./build-formats python",
                "./build-tests python python-write"
            )
            break
        }
        "test" {
            $execCmds = @(
                "./build-formats python",
                "./build-tests python python-write",
                "./run-python"
            )
            break
        }
        "ci" {
            $execCmds = @(
                "./build-formats python",
                "./build-tests python python-write",
                "./ci-python"
            )
            break
        }
        "itest" { 
            $cc = Get-CliContext
            if ([string]::IsNullOrEmpty($cc.RelMountToPwd)) { exit 1 }
            $target = $cc.RelMountToPwd + ($args[1] ? "/$($args[1])" : '')

            $execEnvs = @(
                "KST_INSTANT=1"
                "LOCAL_KST_PATH=$target"
            )
            $execCmds = @(
                "./build-formats python"
                "./build-tests python python-write"
                "./run-python"
            )
        }
        "ici" {
            $cc = Get-CliContext
            if ([string]::IsNullOrEmpty($cc.RelMountToPwd)) { exit 1 }
            $target = $cc.RelMountToPwd + ($args[1] ? "/$($args[1])" : '')

            $execEnvs = @(
                "KST_INSTANT=1"
                "LOCAL_KST_PATH=$target"
                "LOCAL_KST_TEST_OUT_PATH=$target/test_out"
            )
            $execCmds = @(
                "./build-formats python"
                "./build-tests python python-write"
                "./ci-python"
            )
        }
        "create" {
            $kstDir = $args[1]
            $testKstBaseDir = $args[2]

            $cc = Get-CliContext

            $createKstParam = @{
                TargetDir = $kstDir
                MountPath = $cc.AbsMountDir
                Context   = @{
                    Profile = @{
                        LocalKstSrcPath = $cc.ExistsKstSingleSource ? $cc.SingleSource : $null
                    }
                }
            }

            $kst = New-Kst @createKstParam

            if ($args.Count -lt 3 ) { exit 0 }

            $createTestKstParam = @{
                TargetDir = "$($createKstParam.TargetDir)/.tests"
                MountPath = $cc.AbsMountDir
                Context   = @{
                    Config  = @{
                        TestOut = "/workspace/$($kst.RelMountToKst)/test_out"
                    }
                    Profile = @{
                        LocalKstSrcPath = $cc.ExistsKstSingleSource ? $cc.SingleSource : $null
                    }
                }
            }
            $copyParam = @{
                SrcDir   = $testKstBaseDir
                DestDir  = $createTestKstParam.TargetDir
                OnlyTest = $true
            }

            New-Kst @createTestKstParam > $null
            exit (Copy-Kst @copyParam ? 0 : 1)
        }
        "copy" {
            $cc = Get-CliContext
            $srcDir, $destDir, $onlyTest = switch ($args.Count) {
                2 { @($cc.ExistsKstProfile ? $cc.RelPwdToKst : ".", $args[1], $false) }
                3 { $args[-1] -is [bool] ? @($cc.ExistsKstProfile ? $cc.RelPwdToKst : ".", $args[1], $args[2]) : @($args[1], $args[2], $false) }
                4 { @($args[1], $args[2], $args[3]) }
                default { exit 1 }
            }

            if ((Copy-Kst $srcDir $destDir $onlyTest)) {
                exit 0;
            }
            else {
                exit 1
            }
        }
        "clear" {
            $cc = Get-CliContext
            $dir = switch ($args.Count) {
                1 { $cc.ExistsKstProfile ? $cc.RelPwdToKst : $PWD }
                2 { $args[1] -ne "--virtual" ? $args[1] : $PWD }
                3 { $args[1] -ne "--virtual" ? $args[1] : $args[2] }
            }
            if (-not (Test-Path -Path $dir)) { exit 1 }

            # TODO: Create function then, support WhatIf.
            if ("--virtual" -in $args) {
                @(
                    Get-ChildItem -Path "$dir/compiled/*" -Recurse
                    Get-ChildItem -Path "$dir/spec/*" -Directory
                        | Where-Object { $_.Name -ne "ks" }
                        | ForEach-Object { Get-ChildItem -Path $_ -Recurse }
                )
                exit 0
            }
            
            Remove-Item -Path "$dir/compiled/*" -Recurse
            Get-ChildItem -Path "$dir/spec" -Directory
                | Where-Object { $_.Name -ne "ks" }
                | Remove-Item -Recurse
            exit 0
        }
        "push" {
            $cc = Get-CliContext
            if (-not $cc.ExistsKstProfile) { exit 1 }

            $thisDir = $cc.RelPwdToKst

            $copyParam = @{
                SrcDir   = $thisDir
                DestDir  = $args[1]
                OnlyTest = $false
            }

            exit (Copy-Kst @copyParam ? 0 : 1)
        }
        "pull" {
            $cc = Get-CliContext
            if (-not $cc.ExistsKstProfile) { exit 1 }

            $thisDir = $cc.RelPwdToKst

            $copyParam = @{
                SrcDir   = $args[1]
                DestDir  = $thisDir
                OnlyTest = $false
            }

            exit (Copy-Kst @copyParam ? 0 : 1)
        }
        "push-test" {
            $cc = Get-CliContext
            if (-not $cc.ExistsKstProfile) { exit 1 }

            $thisDir = $cc.RelPwdToKst

            $copyParam = @{
                SrcDir   = $thisDir
                DestDir  = "$($args[1])/.tests"
                OnlyTest = $true
            }

            exit (Copy-Kst @copyParam ? 0 : 1)
        }
        "pull-test" {
            $cc = Get-CliContext
            if (-not $cc.ExistsKstProfile) { exit 1 }

            $thisDir = $cc.RelPwdToKst
            $testDir = "$thisDir/.tests"

            $copyParam = @{
                SrcDir   = $args[1]
                DestDir  = $testDir
                OnlyTest = $true
            }

            exit (Copy-Kst @copyParam ? 0 : 1)
        }
        "test-merge" {
            $cc = Get-CliContext
            if (-not $cc.ExistsKstProfile) { exit 1 }

            $thisDir = $cc.RelPwdToKst
            $testDir = "$thisDir/.tests"

            $copyParam = @{
                SrcDir   = $thisDir
                DestDir  = $testDir
                OnlyTest = $true
            }

            if (Copy-Kst @copyParam) {
                pwsh -Command "& '$testDir/$KST_SCRIPT_NAME' run-test"
                exit 0
            }
            else {
                exit 1
            }
        }
        "ci-merge" {
            $cc = Get-CliContext
            if (-not $cc.ExistsKstProfile) { exit 1 }

            $thisDir = $cc.RelPwdToKst
            $testDir = "$thisDir/.tests"

            $copyParam = @{
                SrcDir   = $thisDir
                DestDir  = $testDir
                OnlyTest = $true
            }

            if (Copy-Kst @copyParam) {
                pwsh -Command "& '$testDir/$KST_SCRIPT_NAME' run-ci"
                exit 0
            }
            else {
                exit 1
            }
        }
        "create-command" {
            $createCmdParam = switch ($args.Count) {
                1 { @{ TargetDir = '.' }; break }
                2 { $args[1] -is [hashtable] ? $args[1] : @{ TargetDir = $args[1] }; break }
                3 { @{ TargetDir = $args[1]; DockerMountPath = $args[2] }; break }
                4 { @{ TargetDir = $args[1]; DockerMountPath = $args[2]; DockerImageName = $args[3] }; break }
                5 { @{ TargetDir = $args[1]; DockerMountPath = $args[2]; DockerImageName = $args[3]; DockerfilePath = $args[4] }; break }
                default { exit 1 }
            }

            exit ((New-ProjectKstCommand @createCmdParam) ? 0 : 1)
        }
        "context" {
            Get-CliContext
            exit 0
        }
        "help" {
            Show-Usage
            exit 0
        }
        "about" {
            $execCmds = @(
                "echo Kaitai Struct Test Tool"
                "echo version: $ABOUT_VERSION"
                "echo repository: $ABOUT_REPOSITORY"
                "echo"
                "cd /ks"
                "echo Kaitai Struct:\\n `$(git rev-parse HEAD)"
                # "echo Kaitai Struct:\\n `$(git remote get-url origin | sed -e 's/git@github.com:/https:\/\/github.com\//' -e 's/\.git$//')/commit/`$(git rev-parse HEAD)"
                "echo Kaitai Struct submodules:"
                "git submodule status"
                "echo ksc:\\n `$(command -v ksc > /dev/null 2>&1 && ksc --version)"
                "echo ksv:\\n `$(command -v ksv > /dev/null 2>&1 && ksv --version)"
                "echo ksdump:\\n `$(command -v ksdump > /dev/null 2>&1 && ksdump --version)"
                "echo java:\\n `$(command -v java > /dev/null 2>&1 && java --version)"
                "echo ruby:\\n `$(command -v ruby > /dev/null 2>&1 && ruby --version)"
                "echo python:\\n `$(command -v python > /dev/null 2>&1 && python --version)"
                "echo pip:\\n `$(command -v pip > /dev/null 2>&1 && pip --version)"
                "echo pip packages:\\n `$(command -v pip > /dev/null 2>&1 && pip list --format=freeze)"
                "echo gem:\\n `$(command -v gem > /dev/null 2>&1 && gem list)"
                "echo sbt:\\n `$(command -v sbt > /dev/null 2>&1 && sbt --version 2>&1 | grep -v '\[info\]')"
            )
            break
        }
        "rebuild-image" {
            $cc = Get-CliContext
            
            docker image rmi $cc.DockerImageName

            $execCmds = @(
                "echo `"The docker image is ready.`""
            )
            break
        }
        Default {
            if ($args[0] -is [array]) {
                $execCmds = $args[0]
            } else {
                $allArgs = $args -join " "
                $execCmds = @($allArgs)
            }
            break
        }
    }
}

Invoke-Docker -Commands $execCmds -Envs $execEnvs
