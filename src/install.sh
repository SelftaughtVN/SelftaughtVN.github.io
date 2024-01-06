# Total build time > 30min, mostly from building kaldi

# Locations variables
SRC=$(realpath .) &&
KALDI=$(realpath kaldi) &&
VOSK=$(realpath vosk) &&
OPENFST=$(realpath openfst) &&
LIBARCHIVE=$(realpath libarchive) &&
ZSTD=$(realpath zstd) && 
CLAPACK_WASM=$(realpath clapack-wasm) &&

# Activate and add (the directory containing) wasm-ld to PATH
source ../../emsdk/emsdk_env.sh &&
export PATH=:$PATH:$(realpath ../../emsdk/upstream/bin) &&

# In-place: make install to /tmp, delete root, and move back to correct directory if possible to save disk space or else the whole repo will take > 4GB

# In-place: zstd 1.5.5
cd $ZSTD && 
rm -rf /tmp/zstd &&
PREFIX=/tmp/zstd CPPFLAGS=-O3 LDFLAGS=-O3 emmake make install &&
rm -rf $ZSTD && 
mv /tmp/zstd $ZSTD && 

# In-place: libarchive 3.7.2
cd $LIBARCHIVE && 
rm -rf /tmp/libarchive &&
build/autogen.sh && 
CPPFLAGS=-I$ZSTD/include LDFLAGS=-L$ZSTD/lib emconfigure ./configure --prefix=/tmp/libarchive --without-lz4 --without-lzma --without-zlib --without-bz2lib --without-xml2 --without-expat --without-cng --without-openssl --without-libb2 --disable-bsdunzip --disable-xattr --disable-acl --disable-bsdcpio --disable-bsdcat --disable-rpath --disable-maintainer-mode --disable-dependency-tracking --enable-static --disable-shared && 
emmake make install &&
rm -rf $LIBARCHIVE && 
mv /tmp/libarchive $LIBARCHIVE &&

# clapack-wasm ?.?.?
cd $CLAPACK_WASM &&
# Rename the main function in main.c otherwise it would be called instead of mine
git apply $SRC/clapack-wasm.patch &&
bash ./install_repo.sh emcc 

# In-place: openfst 1.8.0 
cd $OPENFST &&
# I don't know why, but I have to run this twice
autoreconf -ifs
autoreconf -ifs
CXXFLAGS="-pthread -r -O3"  LDFLAGS="-O3 -pthread" emconfigure ./configure --prefix=$KALDI/tools/openfst --enable-static --disable-shared --enable-ngram-fsts --enable-lookahead-fsts --disable-bin --with-pic && 
emmake make install &&
rm -rf $OPENFST &&
OPENFST=$KALDI/tools/openfst &&
# Quick fake Makefile to bypass Kaldi's openfst version check
echo "PACKAGE_VERSION = 1.8.0" >> $OPENFST/Makefile &&

# Kaldi ?.?.? (the beast)
cd $KALDI/src &&
# Remove tests because they will always fail when building to wasm
git apply $SRC/kaldi.patch &&
CXXFLAGS="-O3 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -msimd128 -UHAVE_EXECINFO_H -pthread" LDFLAGS="-O3 -sERROR_ON_UNDEFINED_SYMBOLS=0 -lembind -pthread" emconfigure ./configure --use-cuda=no --with-cudadecoder=no --static --static-math=yes --static-fst=yes --clapack-root=$CLAPACK_WASM --host=WASM && 
emmake make online2bin lm rnnlm &&

# In-place: vosk 0.3.45
cd $VOSK/src &&
VOSK_FILES="recognizer.cc language_model.cc model.cc spk_model.cc vosk_api.cc" &&
em++ -pthread -O3 -I. -I$KALDI/src -I$OPENFST/include $VOSK_FILES -c &&
emar -rcs vosk.a ${VOSK_FILES//.cc/.o} &&

# Finally build asr engine
cd $SRC && 
em++ -O3 asr.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -flto=full -fno-rtti -fno-exceptions -sINITIAL_MEMORY=35mb -sASYNCIFY -sPTHREAD_POOL_SIZE=2 -pthread -sPROXY_TO_PTHREAD -I$LIBARCHIVE/include -I$VOSK/src -L$LIBARCHIVE/lib -larchive -L$ZSTD/lib -lzstd -L$KALDI/src -l:online2/kaldi-online2.a -l:decoder/kaldi-decoder.a -l:ivector/kaldi-ivector.a -l:gmm/kaldi-gmm.a -l:tree/kaldi-tree.a -l:feat/kaldi-feat.a -l:cudamatrix/kaldi-cudamatrix.a -l:lat/kaldi-lat.a -l:lm/kaldi-lm.a -l:rnnlm/kaldi-rnnlm.a -l:hmm/kaldi-hmm.a -l:nnet3/kaldi-nnet3.a -l:transform/kaldi-transform.a -l:matrix/kaldi-matrix.a -l:fstext/kaldi-fstext.a -l:util/kaldi-util.a -l:base/kaldi-base.a -L$OPENFST/lib -l:libfst.a -l:libfstngram.a -L$CLAPACK_WASM -l:CBLAS/lib/cblas.a -l:CLAPACK-3.2.1/lapack.a -l:CLAPACK-3.2.1/libcblaswr.a -l:f2c_BLAS-3.8.0/blas.a -l:libf2c/libf2c.a -L$VOSK/src -l:vosk.a -lopfs.js -lopenal -o asr.js
