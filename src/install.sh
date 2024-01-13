# Total build time > 30min, mostly from building kaldi

sudo apt install shtool libtool autogen autotools-dev pkg-config &&

SRC=$(realpath .) &&
KALDI=$(realpath kaldi) &&
VOSK=$(realpath vosk) &&
OPENFST=$KALDI/tools/openfst &&
LIBARCHIVE=$(realpath libarchive) &&
ZSTD=$(realpath zstd) && 
CLAPACK_WASM=$(realpath clapack-wasm) &&

source ../../emsdk/emsdk_env.sh &&
export PATH=:$PATH:$(realpath ../../emsdk/upstream/bin) &&

git clone -b v1.5.5 --depth=1 https://github.com/facebook/zstd /tmp/zstd &&
cd /tmp/zstd && 
HAVE_THREAD=0 ZSTD_LEGACY_SUPPORT=0 HAVE_ZLIB=0 HAVE_LZMA=0 HAVE_LZ4=0 ZSTD_NOBENCH=1 ZSTD_NODICT=1 ZSTD_NOCOMPRESS=1 BACKTRACE=0 ZSTD_STATIC_LINKING_ONLY=1 PREFIX=$SRC/zstd CPPFLAGS="-O3 -flto" LDFLAGS="-O3 -flto" emmake make install &&
rm -rf /tmp/zstd &&

git clone -b v3.7.2 --depth=1 https://github.com/libarchive/libarchive /tmp/libarchive
cd /tmp/libarchive && 
build/autogen.sh && 
CPPFLAGS="-I$ZSTD/include -flto" LDFLAGS="-L$ZSTD/lib -flto" emconfigure ./configure --prefix=$SRC/libarchive --without-lz4 --without-lzma --without-zlib --without-bz2lib --without-xml2 --without-expat --without-cng --without-openssl --without-libb2 --disable-bsdunzip --disable-xattr --disable-acl --disable-bsdcpio --disable-bsdcat --disable-rpath --disable-maintainer-mode --disable-dependency-tracking --enable-static --disable-shared && 
emmake make install &&
rm -rf /tmp/libarchive &&

git clone --depth=1 https://gitlab.inria.fr/multispeech/kaldi.web/clapack-wasm
cd $CLAPACK_WASM &&
git apply $SRC/clapack-wasm.patch &&
bash ./install_repo.sh emcc 

git clone --depth=1 https://github.com/alphacep/openfst /tmp/openfst
cd /tmp/openfst &&
autoreconf -i &&
CXXFLAGS="-pthread -r -O3 -flto"  LDFLAGS="-O3 -pthread -flto" emconfigure ./configure --prefix=$OPENFST --enable-static --disable-shared --enable-ngram-fsts --enable-lookahead-fsts --disable-bin --with-pic && 
emmake make install &&
echo "PACKAGE_VERSION = 1.8.0" >> $OPENFST/Makefile &&

git clone -b vosk --depth=1https://github.com/alphacep/kaldi
cd $KALDI/src &&
# Remove tests because they will always fail when building to wasm
git apply $SRC/kaldi.patch &&
CXXFLAGS="-O3 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -msimd128 -UHAVE_EXECINFO_H -pthread -flto" LDFLAGS="-O3 -sERROR_ON_UNDEFINED_SYMBOLS=0 -lembind -pthread -flto" emconfigure ./configure --use-cuda=no --with-cudadecoder=no --static --static-math=yes --static-fst=yes --double-precision=yes --debug-level=0 --clapack-root=$CLAPACK_WASM --host=WASM && 
emmake make online2 lm rnnlm &&

git clone -b go/v0.3.46 --depth=1 https://github.com/alphacep/vosk-api
cd $VOSK/src &&
VOSK_FILES="recognizer.cc language_model.cc model.cc spk_model.cc vosk_api.cc" &&
em++ -pthread -O3 -flto -I. -I$KALDI/src -I$OPENFST/include $VOSK_FILES -c &&
emar -rcs vosk.a ${VOSK_FILES//.cc/.o} &&

cd $SRC && 
em++ -O3 asre.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sINITIAL_MEMORY=300mb -sASYNCIFY -sPTHREAD_POOL_SIZE=2 -pthread -flto -I$LIBARCHIVE/include -I$VOSK/src -L$LIBARCHIVE/lib -larchive -L$ZSTD/lib -lzstd -L$KALDI/src -l:online2/kaldi-online2.a -l:decoder/kaldi-decoder.a -l:ivector/kaldi-ivector.a -l:gmm/kaldi-gmm.a -l:tree/kaldi-tree.a -l:feat/kaldi-feat.a -l:cudamatrix/kaldi-cudamatrix.a -l:lat/kaldi-lat.a -l:lm/kaldi-lm.a -l:rnnlm/kaldi-rnnlm.a -l:hmm/kaldi-hmm.a -l:nnet3/kaldi-nnet3.a -l:transform/kaldi-transform.a -l:matrix/kaldi-matrix.a -l:fstext/kaldi-fstext.a -l:util/kaldi-util.a -l:base/kaldi-base.a -L$OPENFST/lib -l:libfst.a -l:libfstngram.a -L$CLAPACK_WASM -l:CBLAS/lib/cblas.a -l:CLAPACK-3.2.1/lapack.a -l:CLAPACK-3.2.1/libcblaswr.a -l:f2c_BLAS-3.8.0/blas.a -l:libf2c/libf2c.a -L$VOSK/src -l:vosk.a -lopfs.js -lopenal -o asre.js
