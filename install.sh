# Activate and add (the directory containing) wasm-ld to PATH
source ../emsdk/emsdk_env.sh  
export PATH=:$PATH:$(realpath ../upstream/bin)
# Make install zstd 1.5.5, libarchive 3.7.2, and clapack-wasm in a separate process
#In-place install (make install to /tmp, delete and mv back) if possible to save disk space (if not the whole will take > 3GB)
(
cd src/zstd && 
rm -rf /tmp/zstd &&
PREFIX=/tmp/zstd emmake make -j 4 install &&
cd .. && 
rm -rf zstd && 
mv /tmp/zstd zstd &&
cd libarchive && 
rm -rf /tmp/libarchive &&
build/autogen.sh && 
emconfigure ./configure --prefix=/tmp/libarchive --without-lz4 --without-lzma --without-zlib --without-bz2lib --without-xml2 --without-expat --without-cng --without-openssl --without-libb2 --disable-bsdunzip --disable-xattr --disable-acl --disable-bsdcpio --disable-bsdcat --disable-rpath --disable-maintainer-mode --disable-dependency-tracking --disable-shared --enable-bsdtar=static CPPFLAGS='-O3 -I../zstd/lib' LDFLAGS='-O3 -L../zstd/lib' && 
emmake make -j 4 install &&
cd .. && 
rm -rf libarchive && 
mv /tmp/libarchive libarchive &&
cd clapack-wasm &&
./install_repo.sh emcc
) &
# Make install openfst 1.8.0 in this process (this thing takes years)
cd src/openfst &&
autoupdate && 
autoreconf -if && 
CFLAGS="-g -O3" LDFLAGS=-O3 emconfigure ./configure --prefix=$(realpath ../kaldi/tools/openfst) --enable-static --disable-shared --enable-far --enable-ngram-fsts --enable-lookahead-fsts --with-pic && 
emmake make -j 4 install &&
cd .. && 
rm -rf openfst &&
#Quick fake Makefile to bypass kaldi's openfst version check
echo "PACKAGE_VERSION = 1.8.0" >> kaldi/tools/openfst/Makefile &&
wait &&
# Make kaldi 
cd ../../src &&
CXXFLAGS=-O3 LDFLAGS=-O3 emconfigure ./configure --use-cuda=no --static --static-math=yes --static-fst=yes --clapack-root=../../clapack-wasm --host=WASM &&
EMCC_CFLAGS='-msimd128 -U HAVE_EXECINFO_H' emmake make -j 4 online2bin &&
# Make vosk

# Finally build asr engine
cd ../.. &&
em++ -O3 asr.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sINITIAL_MEMORY=35mb -sPTHREAD_POOL_SIZE=2 -pthread -Ilibarchive/include -Llibarchive/lib -larchive -Lzstd/lib -lzstd -lopfs.js -o ../asr.js
