# Overview
SelftaughtVN is a free Vietnamese learning website that provides basic-to-advance 4-skill Vietnamese practice. This repository hosts the code for SelftaughtVN.github.io

Files are organized into two categories. Inside the "src" folder are easy-to-read source code. Files outside it are for deployments to the actual webpage where they are optimized for loading.
# Build guides
Following this will build the whole website from the source, currently only available on the branch "asr-implementation" as I am working on the ASR engine. Download everything to your $HOME.
1. Follow the guide on the official [website](https://emscripten.org/docs/getting_started/downloads.html) and download Emscripten 3.1.51 through emsdk
2. Download [libarchive 3.7.2](https://github.com/libarchive/libarchive/releases/download/v3.7.2/libarchive-3.7.2.tar.gz) as "libarchive-3.7.2" (source files has to be directly under the folder).
3. Do:
```
git clone https://github.com/SelftaughtVN/SelftaughtVN.github.io -b asr-implementation --single-branch && 
source $HOME/emsdk/emsdk_env.sh &&
cd $HOME/libarchive-3.7.2 &&
emconfigure ./configure &&
emmake make -sSIDE_MODULE=1 && 
cd $HOME/SelftaughtVN.github.io &&
em++ asr.cpp -flto=full -O3 -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sPROXY_TO_PTHREAD -pthread -I$HOME/libarchive-3.7.2/libarchive -L$HOME/libarchive-3.7.2/.libs -larchive -lopfs.js -o asr.js
```
