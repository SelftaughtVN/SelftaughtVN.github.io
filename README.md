# Overview
SelftaughtVN is a free Vietnamese learning website that provides basic-to-advance 4-skill Vietnamese practice. This repository hosts the code for SelftaughtVN.github.io

Files are organized into two categories. Inside the "src" folder are easy-to-read source code. Files outside it are for deployments to the actual webpage where they are optimized and compiled for loading.
# Build guides
Following this will build the whole website from source, currently only available on this branch (asr-implementation) as I am working on the ASR engine. Download everything to the same directory.
1. Follow the guide on the official [Emscripten website](https://emscripten.org/docs/getting_started/downloads.html) and download v3.1.51 through emsdk.
2. And do:
```
git clone https://github.com/SelftaughtVN/SelftaughtVN.github.io -b asr-implementation --single-branch --recurse-submodules &&
cd SelftaughtVN.github.io &&
./install.sh
```
