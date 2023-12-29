# Activate
source ../emsdk/emsdk_env.sh  
# Make install zstd 1.5.5, libarchive 3.7.2, and clapack in a separate process
(
cd src/zstd && rm -rf /tmp/zstd
PREFIX=/tmp/zstd emmake make -j 4 install &&
cd .. && rm -rf zstd && mv /tmp/zstd zstd
cd libarchive && rm -rf /tmp/libarchive &&
build/autogen.sh && 
emconfigure ./configure --prefix=/tmp/libarchive --without-lz4 --without-lzma --without-zlib --without-bz2lib --without-xml2 --without-expat --without-cng --without-openssl --without-libb2 --disable-bsdunzip --disable-xattr --disable-acl --disable-bsdcpio --disable-bsdcat --disable-rpath --disable-maintainer-mode --disable-dependency-tracking --disable-shared --enable-bsdtar=static CPPFLAGS='-O3 -I../zstd/lib' LDFLAGS='-O3 -L../zstd/lib' && 
emmake make -j 4 install &&
cd .. && rm -rf libarchive && mv /tmp/libarchive libarchive
cd clapack && rm -rf /tmp/clapack
git apply ../clapack.patch --whitespace=fix &&
emcmake cmake &&
PREFIX=/tmp/clapack/F2CLIBS emmake make -j 4 -C  F2CLIBS install &&
PREFIX=/tmp/clapack/BLAS emmake make -j 4 -C BLAS install &&
PREFIX=/tmp/clapack/SRC emmake make -j 4 -C SRC install &&
cd .. && rm -rf clapack && mv /tmp/clapack ../kaldi/tools/clapack 
) &
# Make install openfst 1.8.0 in this process (this thing takes years)
cd src/openfst &&
autoupdate && autoreconf -if && 
CFLAGS="-g -O3" LDFLAGS=-O3 emconfigure ./configure --prefix=$(realpath ../kaldi/tools/openfst) --enable-static --disable-shared --enable-far --enable-ngram-fsts --enable-lookahead-fsts --with-pic && 
emmake make -j 4 install &&
cd .. && rm -rf openfst &&
wait &&
# Make kaldi 
cd ../kaldi/src &&
CXXFLAGS=-O3 LDFLAGS=-O3 emconfigure ./configure --use-cuda=no --static --static-math=yes --static-fst=yes --clapack-root=../../clapack --host=WASM &&
emmake make -j 4 &&
# Make vosk
# Finally build asr engine
cd ../.. &&
em++ -O3 asr.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sINITIAL_MEMORY=35mb -sPTHREAD_POOL_SIZE=2 -pthread -Ilibarchive/built/include -Llibarchive/built/libs -larchive -Lzstd/built/lib -lzstd -lopfs.js -o ../asr.js
