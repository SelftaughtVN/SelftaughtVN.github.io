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

# zstd 1.5.5, libarchive 3.7.2, clapack-wasm in a separate process (in-place)
(
    cd $ZSTD && 
    rm -rf /tmp/zstd &&
    PREFIX=/tmp/zstd emmake make -j 4 install &&
    rm -rf $ZSTD && 
    mv /tmp/zstd $ZSTD && 

    cd $LIBARCHIVE && 
    rm -rf /tmp/libarchive &&
    build/autogen.sh && 
    emconfigure ./configure --prefix=/tmp/libarchive --without-lz4 --without-lzma --without-zlib --without-bz2lib --without-xml2 --without-expat --without-cng --without-openssl --without-libb2 --disable-bsdunzip --disable-xattr --disable-acl --disable-bsdcpio --disable-bsdcat --disable-rpath --disable-maintainer-mode --disable-dependency-tracking --enable-static --disable-shared CPPFLAGS="-O3 -I$ZSTD/include" LDFLAGS="-O3 -L$ZSTD/lib" && 
    emmake make -j 4 install &&
    rm -rf $LIBARCHIVE && 
    mv /tmp/libarchive $LIBARCHIVE &&

    cd $CLAPACK_WASM &&
    git apply $SRC/clapack-wasm.patch &&
    bash ./install_repo.sh emcc
) &

# In-place: openfst 1.8.0 in this process (this thing also takes years)
cd $OPENFST &&
autoupdate && 
autoreconf -if && 
CFLAGS="-g -O3" LDFLAGS=-O3 emconfigure ./configure --prefix=$(realpath ../kaldi/tools/openfst) --enable-static --disable-shared --enable-ngram-fsts --enable-lookahead-fsts --disable-bin --with-pic && 
emmake make -j 4 install &&
rm -rf $OPENFST &&
# Quick fake Makefile to bypass Kaldi's openfst version check
echo "PACKAGE_VERSION = 1.8.0" >> $KALDI/tools/openfst/Makefile &&
wait &&

# Make kaldi (more thread because this takes the longest)
cd $KALDI &&
git apply $SRC/kaldi.patch &&
cd $KALDI/src &&
CXXFLAGS="-O3 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -msimd128 -UHAVE_EXECINFO_H" LDFLAGS="-O3 -sERROR_ON_UNDEFINED_SYMBOLS=0 -lembind" emconfigure ./configure --use-cuda=no --with-cudadecoder=no --static --static-math=yes --static-fst=yes --clapack-root=$CLAPACK_WASM --host=WASM && 
emmake make -j 6 
:'
# Make vosk (modify Makefile to parallel make)
cd $VOSK &&
git apply $SRC/vosk.patch &&
cd $VOSK/src &&
KALDI=$KALDI CLAPACK_WASM=$CLAPACK_WASM emmake make -j 4 &&

# Finally build asr engine
OPENFST=$KALDI/tools/openfst &&
cd $SRC && 
em++ -O3 asr.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sINITIAL_MEMORY=35mb -sPTHREAD_POOL_SIZE=2 -pthread -I$LIBARCHIVE/include -I$VOSK/src -L$LIBARCHIVE/lib -larchive -L$ZSTD/lib -lzstd -L$KALDI/src/online2 -l:kaldi-online2.a -L$KALDI/src/decoder -l:kaldi-decoder.a -L$KALDI/src/ivector -l:kaldi-ivector.a -L$KALDI/src/gmm -l:kaldi-gmm.a -L$KALDI/src/tree -l:kaldi-tree.a -L$KALDI/src/feat -l:kaldi-feat.a -L$KALDI/src/cudamatrix -l:kaldi-cudamatrix.a -L$KALDI/src/lat -l:kaldi-lat.a -L$KALDI/src/lm -l:kaldi-lm.a -L$KALDI/src/rnnlm -l:kaldi-rnnlm.a -L$KALDI/src/hmm -l:kaldi-hmm.a -L$KALDI/src/nnet3 -l:kaldi-nnet3.a -L$KALDI/src/transform -l:kaldi-transform.a -L$KALDI/src/matrix -l:kaldi-matrix.a -L$KALDI/src/fstext -l:kaldi-fstext.a -L$KALDI/src/util -l:kaldi-util.a -L$KALDI/src/base -l:kaldi-base.a -L$OPENFST/lib -l:libfst.a -L$OPENFST/lib -l:libfstngram.a -L$CLAPACK_WASM/CBLAS/lib -l:cblas.a -L$CLAPACK_WASM/CLAPACK-3.2.1 -l:lapack.a -l:libcblaswr.a -L$CLAPACK_WASM/f2c_BLAS-3.8.0 -l:blas.a -L$CLAPACK_WASM/libf2c -l:libf2c.a -L$VOSK/src -l:vosk.a -lopfs.js -lopenal -o $SRC/asr.js &&

# Cleanup
rm -rf $CLAPACK_WASM $KALDI $LIBARCHIVE $VOSK $ZSTD
'
