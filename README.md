# Overview
SelftaughtVN is a free Vietnamese learning website that provides basic-to-advance 4-skill Vietnamese practice. This repository hosts the code for SelftaughtVN.github.io

Files are organized into two categories. Inside the "src" folder are easy-to-read source code. Files outside it are for deployments to the actual webpage where they are optimized for loading.
# Build guides
Following this will build the whole website from source, currently only available on this branch (asr-implementation) as I am working on the ASR engine. Download everything to your $HOME.
1. Follow the guide on the official [Emscripten website](https://emscripten.org/docs/getting_started/downloads.html) and downoad v3.1.51 through emsdk
2. Download and extract [libarchive 3.7.2](https://github.com/libarchive/libarchive/releases/download/v3.7.2/libarchive-3.7.2.tar.gz) as "libarchive-3.7.2" (source files has to be directly under the folder).
3. Download and extract [zstd 1.5.5](https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-1.5.5.tar.gz) as "zstd-1.5.5" (source files has to be directly under the folder).
4. Finally do:
```
git clone https://github.com/SelftaughtVN/SelftaughtVN.github.io -b asr-implementation --single-branch && 
source $HOME/emsdk/emsdk_env.sh &&
cd $HOME/zstd-1.5.5 &&
emmake make &&
cd $HOME/libarchive-3.7.2 &&
emconfigure ./configure --without-lz4 --without-lzma --without-zlib --without-bz2lib --without-xml2 --without-expat --without-cng --without-openssl --without-libb2 --disable-bsdunzip --disable-xattr --disable-acl --disable-bsdcpio --disable-bsdcat --disable-rpath --disable-maintainer-mode --disable-dependency-tracking --disable-shared --enable-bsdtar=static CPPFLAGS=-I$HOME/zstd-1.5.5/lib LDFLAGS=-L$HOME/zstd-1.5.5/lib &&
emmake make && 
cd $HOME/SelftaughtVN.github.io &&
em++ -O3 src/asr.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sINITIAL_MEMORY=35mb -sPTHREAD_POOL_SIZE=2 -pthread -I$HOME/libarchive-3.7.2/libarchive -L$HOME/libarchive-3.7.2/.libs -larchive -L$HOME/zstd-1.5.5/lib -lzstd -lopfs.js -o asr.js
```
