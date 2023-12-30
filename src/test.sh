#Locations variables
SRC=$(realpath ./)
KALDI=$(realpath kaldi)
VOSK=$(realpath vosk)
OPENFST=$KALDI/tools/openfst
LIBARCHIVE=$(realpath libarchive)
ZSTD=$(realpath zstd)
CLAPACK_WASM=$(realpath clapack-wasm)
em++ -O3 asr.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sINITIAL_MEMORY=35mb -sPTHREAD_POOL_SIZE=2 -pthread -I$LIBARCHIVE/include -I$VOSK/src -L$LIBARCHIVE/lib -larchive -L$ZSTD/lib -l:libzstd.a -L$KALDI/src/online2 -l:kaldi-online2.a -L$KALDI/src/decoder -l:kaldi-decoder.a -L$KALDI/src/ivector -l:kaldi-ivector.a -L$KALDI/src/gmm -l:kaldi-gmm.a -L$KALDI/src/tree -l:kaldi-tree.a -L$KALDI/src/feat -l:kaldi-feat.a -L$KALDI/src/cudamatrix -l:kaldi-cudamatrix.a -L$KALDI/src/lat -l:kaldi-lat.a -L$KALDI/src/lm -l:kaldi-lm.a -L$KALDI/src/rnnlm -l:kaldi-rnnlm.a -L$KALDI/src/hmm -l:kaldi-hmm.a -L$KALDI/src/nnet3 -l:kaldi-nnet3.a -L$KALDI/src/transform -l:kaldi-transform.a -L$KALDI/src/matrix -l:kaldi-matrix.a -L$KALDI/src/fstext -l:kaldi-fstext.a -L$KALDI/src/util -l:kaldi-util.a -L$KALDI/src/base -l:kaldi-base.a -L$OPENFST/lib -l:libfst.a -L$OPENFST/lib -l:libfstngram.a -L$CLAPACK_WASM/CBLAS/lib -l:cblas.a -L$CLAPACK_WASM/CLAPACK-3.2.1 -l:lapack.a -l:libcblaswr.a -L$CLAPACK_WASM/f2c_BLAS-3.8.0 -l:blas.a -L$CLAPACK_WASM/libf2c -l:libf2c.a -L$VOSK/src -l:vosk.a -lopfs.js -lopenal -o ../asr.js

# Cleanup
#rm -rf $CLAPACK_WASM $KALDI $LIBARCHIVE $VOSK $ZSTD
