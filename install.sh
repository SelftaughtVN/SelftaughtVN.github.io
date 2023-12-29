#Locations variables
SRC=$(realpath ./)
KALDI=$(realpath kaldi)
VOSK=$(realpath vosk)
OPENFST=$(realpath openfst)
LIBARCHIVE=$(realpath libarchive)
ZSTD=$(realpath zstd)
CLAPACK_WASM=$(realpath clapack-wasm)

# Activate and add (the directory containing) wasm-ld to PATH
source ../../emsdk/emsdk_env.sh  
export PATH=:$PATH:$(realpath ../../emsdk/upstream/bin)

#In-place: make install to /tmp, delete root, and move back to correct directory if possible to save disk space or else the whole repo will take > 4GB

# zstd 1.5.5, libarchive 3.7.2 in a separate process (in-place)
(
    cd $ZSTD && 
    rm -rf /tmp/zstd &&
    PREFIX=/tmp/zstd emmake make -j 4 install &&
    rm -rf $ZSTD && 
    mv /tmp/zstd $ZSTD &&

    cd $LIBARCHIVE && 
    rm -rf /tmp/libarchive &&
    build/autogen.sh && 
    emconfigure ./configure --prefix=/tmp/libarchive --without-lz4 --without-lzma --without-zlib --without-bz2lib --without-xml2 --without-expat --without-cng --without-openssl --without-libb2 --disable-bsdunzip --disable-xattr --disable-acl --disable-bsdcpio --disable-bsdcat --disable-rpath --disable-maintainer-mode --disable-dependency-tracking --disable-shared --enable-bsdtar=static CPPFLAGS='-O3 -I$ZSTD/lib' LDFLAGS='-O3 -L$ZSTD/lib' && 
    emmake make -j 4 install &&
    rm -rf $LIBARCHIVE && 
    mv /tmp/libarchive $LIBARCHIVE 
) &

# Make clapack-wasm (already includes cBLAS) in another process (this thing takes years)
(
    cd $CLAPACK_WASM &&
    bash ./install_repo.sh emcc
) &

# In-place: openfst 1.8.0 in this process (this thing also takes years)
cd $OPENFST &&
autoupdate && 
autoreconf -if && 
CFLAGS="-g -O3" LDFLAGS=-O3 emconfigure ./configure --prefix=$(realpath ../kaldi/tools/openfst) --enable-static --disable-shared --enable-far --enable-ngram-fsts --enable-lookahead-fsts --with-pic && 
emmake make -j 4 install &&
rm -rf $OPENFST &&
# Quick fake Makefile to bypass Kaldi's openfst version check
echo "PACKAGE_VERSION = 1.8.0" >> $KALDI/ &&

wait &&

# Make kaldi 
cd $KALDI &&
CXXFLAGS=-O3 LDFLAGS=-O3 emconfigure ./configure --use-cuda=no --static --static-fst=yes --clapack-root=../../clapack-wasm --host=WASM && 
EMCC_CFLAGS='-msimd128 -U HAVE_EXECINFO_H -sERROR_ON_UNDEFINED_SYMBOLS=0' emmake make clean depend &&
EMCC_CFLAGS='-msimd128 -U HAVE_EXECINFO_H -sERROR_ON_UNDEFINED_SYMBOLS=0' emmake make -j 4 &&

# Make vosk
cd $VOSK/src
KALDI_ROOT=$KALDI emmake make

# Finally build asr engine
cd ../.. &&
em++ -O3 asr.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sINITIAL_MEMORY=35mb -sPTHREAD_POOL_SIZE=2 -pthread -Ilibarchive/include -Llibarchive/lib -larchive -Lzstd/lib -lzstd -lopfs.js -o ../asr.js

# Cleanup
rm -rf $CLAPACK_WASM $KALDI $LIBARCHIVE $VOSK $ZSTD
