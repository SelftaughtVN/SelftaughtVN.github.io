# Overview
SelftaughtVN is a free Vietnamese learning website that provides basic-to-advance 4-skill Vietnamese practice. This repository hosts the code for SelftaughtVN.github.io

Files are organized into two categories. Inside the "src" folder are easy-to-read source code. Files outside it are for deployments to the actual webpage where they are optimized for loading.
# Build guides
Following this will build the whole website from source, currently only available on this branch (asr-implementation) as I am working on the ASR engine. Download everything to your $HOME.
1. Follow the guide on the official [Emscripten website](https://emscripten.org/docs/getting_started/downloads.html) and downoad v3.1.51 through emsdk
2. And do:
```
# Clone and recurse into submodules
git clone https://github.com/SelftaughtVN/SelftaughtVN.github.io -b asr-implementation --single-branch --recurse-submodules && 
#Activate and change directory
cd $HOME/SelftaughtVN.github.io &&
source $HOME/emsdk/emsdk_env.sh &&
# Make zstd 1.5.5
cd ./zstd &&
emmake make &&
# Make libarchive 3.7.2
cd ../libarchive
emconfigure ./configure --without-lz4 --without-lzma --without-zlib --without-bz2lib --without-xml2 --without-expat --without-cng --without-openssl --without-libb2 --disable-bsdunzip --disable-xattr --disable-acl --disable-bsdcpio --disable-bsdcat --disable-rpath --disable-maintainer-mode --disable-dependency-tracking --disable-shared --enable-bsdtar=static CPPFLAGS=-I../zstd/lib LDFLAGS=-L../zstd/lib &&
emmake make && 
# Finally build asr engine
cd .. &&
em++ -O3 src/asr.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sINITIAL_MEMORY=35mb -sPTHREAD_POOL_SIZE=2 -pthread -I../libarchive/libarchive -L../libarchive/.libs -larchive -L../zstd/lib -lzstd -lopfs.js -o asr.js
```
