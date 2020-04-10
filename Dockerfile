
FROM ubuntu:bionic

RUN apt-get update && apt-get install -y -q  \
libexpat1-dev \
zlib1g-dev \
git \
wget \
make \
gcc \
&& rm -rf /var/lib/apt/lists/*

# At least 3.11 is required
ENV CMAKE_VER=cmake-3.13.0-Linux-x86_64
RUN wget -P /cmake  https://github.com/Kitware/CMake/releases/download/v3.13.0/${CMAKE_VER}.tar.gz \
  && cd /cmake \
  && tar xzvf ${CMAKE_VER}.tar.gz \
  && rm -fr ${CMAKE_VER}.tar.gz 
ENV PATH="/cmake/${CMAKE_VER}/bin:$PATH"


RUN mkdir /gifti_clib 
RUN mkdir /gifti_build 
COPY . /gifti_clib/


RUN mkdir /gifti_build_with_prefix 
RUN mkdir /gifti_build_with_sys_nifti

WORKDIR /gifti_build
RUN cmake /gifti_clib \
 -DBUILD_SHARED_LIBS:BOOL=ON \
    && make install \
    && ctest --output-on-failure

WORKDIR /gifti_build_with_sys_nifti
RUN cmake /gifti_clib \
 -DBUILD_SHARED_LIBS:BOOL=ON \
 -DUSE_SYSTEM_NIFTI=ON \
    && make \
    && ctest --output-on-failure

WORKDIR /gifti_build_with_prefix
RUN cmake /gifti_clib \
 -DBUILD_SHARED_LIBS:BOOL=ON \
 -DNIFTI_PACKAGE_PREFIX=test_ \
    && make \
    && ctest --output-on-failure
