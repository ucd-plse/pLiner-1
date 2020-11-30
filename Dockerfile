FROM ubuntu:18.04
# MAINTAINER Lucio Asnaghi <kunitoki@gmail.com>

ARG CMAKE_VERSION=3.17.1

# Install tools
RUN apt-get -qq update -y \
    && apt-get -qq install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        python \
        ninja-build \
        ccache \
        xz-utils \
        curl \
        git \
        vim \
        libncurses5-dev \    
        zlib1g-dev \ 
    && apt-get clean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Add cmake from binary
RUN curl -SL https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh -o /tmp/curl-install.sh \
    && chmod u+x /tmp/curl-install.sh \
    && mkdir /usr/bin/cmake \
    && /tmp/curl-install.sh --skip-license --prefix=/usr/bin/cmake \
    && rm /tmp/curl-install.sh
ENV PATH="/usr/bin/cmake/bin:${PATH}"

# Build clang 9.0.1 from scratch
RUN git clone -b release/9.x https://github.com/llvm/llvm-project.git \ 
    && cd llvm-project \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS=clang -G "Unix Makefiles" ../llvm \ 
    && make \ 
    && make install

# Build pLiner
RUN cd home \
    && git clone https://github.com/ucd-plse/pLiner-forked.git \
    && cd pLiner-forked \
    && git checkout dev \ 
    && cd clang-tool \
    && curl -O https://raw.githubusercontent.com/nlohmann/json/develop/single_include/nlohmann/json.hpp \
    && mkdir build; cd build \
    && cmake .. \
    && make \
    && make install 
