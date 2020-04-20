FROM ubuntu:bionic

RUN apt-get update && apt-get install -y -q  \
    libexpat1-dev \
    zlib1g-dev \
    cmake \
    git \
    wget \
    make \
    gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /opt/src

# At least 3.11 is required for nifti_clib fetching. Install newer cmake
# version with fetchcontent support. Installation can be added to PATH for
# debugging with newer cmake
ENV CMAKE_VER=3.11.3
RUN wget -P /opt/cmake  https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}-Linux-x86_64.tar.gz \
  && cd /opt/cmake \
  && tar xzvf cmake-${CMAKE_VER}-Linux-x86_64.tar.gz \
  && rm -fr cmake-${CMAKE_VER}-Linux-x86_64.tar.gz


# Install nifti manually until a more recent release is made
RUN   cd /tmp \
    && git clone --single-branch --branch update_installation https://github.com/leej3/nifti_clib.git \
    && d=nifti_build;mkdir $d;cd $d \
    && cmake -DDOWNLOAD_TEST_DATA=OFF -DBUILD_SHARED_LIBS=ON ../nifti_clib \
    && make install


# Copy source code into container. Typically invalidates the docker layer caching from here
COPY . /opt/src/gifti_clib/

RUN mkdir /gifti_build
WORKDIR /gifti_build
RUN cmake /opt/src/gifti_clib/ \
        -DBUILD_SHARED_LIBS:BOOL=ON \
        -DUSE_SYSTEM_NIFTI=ON \
        -DDOWNLOAD_TEST_DATA=OFF \
    && make install \
    && ctest --output-on-failure -LE NEEDS_DATA

# Test alternative cmake version:
# ENV PATH="/opt/cmake/cmake-${CMAKE_VER}-Linux-x86_64/bin:$PATH"
# RUN cmake \
#     -DBUILD_SHARED_LIBS=ON \
#     /opt/src/nifti_clib \
#     && make install \
#     && ctest --output-on-failure