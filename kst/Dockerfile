# ==============================================================================
# Copyright (c) 2026 Kita Munemitsu
# This script is released under the MIT License.
# SPDX-License-Identifier: MIT
# ==============================================================================

ARG PYTHON_VERSION=3.12

FROM python:${PYTHON_VERSION}-slim AS simple
RUN apt-get update && apt-get install -y \
    git \
    default-jre-headless \
    ruby-full \
    curl \
    gnupg \
    build-essential \
    && apt-get clean

RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --dearmor -o /etc/apt/keyrings/scalasbt.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/scalasbt.gpg] https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list \
    && apt-get update \
    && apt-get install sbt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ks

RUN git clone --recursive --depth 1 --branch 0.11 https://github.com/kaitai-io/kaitai_struct.git .

COPY build.sbt /ks/tests/translator/build.sbt
COPY build-compiler /ks/tests/build-compiler
COPY build-tests /ks/tests/build-tests
COPY ci-python /ks/tests/ci-python
COPY run-python /ks/tests/run-python

RUN cd /ks/tests \
    && ./build-compiler \
    && cd /ks/compiler \
    && sbt "set ThisBuild / version := \"0.11\"" \
    && sbt publishLocal \
    && cd /ks/tests/translator \
    && sbt compile \
    && mv /ks/tests/formats /ks/tests/formats.bak \
    && mv /ks/tests/spec /ks/tests/spec.bak \
    && mv /ks/tests/src /ks/tests/src.bak \
    && mv /ks/tests/config /ks/tests/config.bak

RUN ln -s "/ks/compiler/jvm/target/universal/stage/bin/kaitai-struct-compiler" "/usr/local/bin/ksc" \
    && ln -s "/ks/compiler/jvm/target/universal/stage/bin/kaitai-struct-compiler" "/usr/local/bin/kaitai-struct-compiler"

RUN pip install --no-cache-dir kaitaistruct unittest-xml-reporting

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]

FROM simple AS inspectable
RUN cd /ks/visualizer \
    && gem build -o ksv.gem kaitai-struct-visualizer \
    && gem install ksv.gem \
    && pip install --no-cache-dir ipython ruamel.yaml
