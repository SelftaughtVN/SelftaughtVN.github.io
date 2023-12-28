# Activate
source ../emsdk/emsdk_env.sh  
# Make install zstd 1.5.5, libarchive 3.7.2, and clapack in a separate process
(
cd src/zstd && 
PREFIX=$(realpath ./built) emmake make install &&
cd ../libarchive &&
build/autogen.sh &&
emconfigure ./configure --prefix=$(realpath ./built) --without-lz4 --without-lzma --without-zlib --without-bz2lib --without-xml2 --without-expat --without-cng --without-openssl --without-libb2 --disable-bsdunzip --disable-xattr --disable-acl --disable-bsdcpio --disable-bsdcat --disable-rpath --disable-maintainer-mode --disable-dependency-tracking --disable-shared --enable-bsdtar=static CPPFLAGS='-O3 -I../zstd/lib' LDFLAGS='-O3 -L../zstd/lib' && 
emmake make install &&
cd ../clapack &&
emcmake cmake && 
emmake make -C F2CLIBS &&
emmake make -C BLAS &&
emmake make -C SRC
) &
# Make install openfst 1.8.0 in this process (this thing takes years)
cd ../openfst &&
autoupdate && 
autoreconf -i -s && 
CFLAGS="-g -O3" LDFLAGS=-O3 emconfigure ./configure --prefix=$(realpath ../kaldi/tools/openfst) --enable-static --disable-shared --enable-far --enable-ngram-fsts --enable-lookahead-fsts --with-pic && 
emmake make -j 4 install &&
ln -sf ../../../openfst/Makefile  ../kaldi/tools/openfst &&
wait &&
# Make kaldi 
cd ../kaldi/src &&
CXXFLAGS=-O3 LDFLAGS=-O3 emconfigure ./configure --use-cuda=no --static --static-math=yes --static-fst=yes --clapack-root=../../clapack --host=WASM &&
emmake make -j 4 &&
# Make vosk
# Finally build asr engine
cd ../.. &&
em++ -O3 asr.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sINITIAL_MEMORY=35mb -sPTHREAD_POOL_SIZE=2 -pthread -Ilibarchive/built/include -Llibarchive/built/libs -larchive -Lzstd/built/lib -lzstd -lopfs.js -o ../asr.js
