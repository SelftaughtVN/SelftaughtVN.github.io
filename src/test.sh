#Locations variables
SRC=$(realpath ./)
KALDI=$(realpath kaldi)
VOSK=$(realpath vosk)
OPENFST=$(realpath openfst)
LIBARCHIVE=$(realpath libarchive)
ZSTD=$(realpath zstd)
CLAPACK_WASM=$(realpath clapack-wasm)
cd $SRC &&
OPENFST=$KALDI/tools/openfst
em++ -O3 $SRC/asr.cpp -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -flto=full -fno-rtti -fno-exceptions -sINITIAL_MEMORY=35mb -sASYNCIFY -sPTHREAD_POOL_SIZE=2 -pthread -sPROXY_TO_PTHREAD -I$LIBARCHIVE/include -I$VOSK/src -L$LIBARCHIVE/lib -larchive -L$ZSTD/lib -lzstd -L$KALDI/src -l:online2/kaldi-online2.a -l:decoder/kaldi-decoder.a -l:ivector/kaldi-ivector.a -l:gmm/kaldi-gmm.a -l:tree/kaldi-tree.a -l:feat/kaldi-feat.a -l:cudamatrix/kaldi-cudamatrix.a -l:lat/kaldi-lat.a -l:lm/kaldi-lm.a -l:rnnlm/kaldi-rnnlm.a -l:hmm/kaldi-hmm.a -l:nnet3/kaldi-nnet3.a -l:transform/kaldi-transform.a -l:matrix/kaldi-matrix.a -l:fstext/kaldi-fstext.a -l:util/kaldi-util.a -l:base/kaldi-base.a -L$OPENFST/lib -l:libfst.a -l:libfstngram.a -L$CLAPACK_WASM -l:CBLAS/lib/cblas.a -l:CLAPACK-3.2.1/lapack.a -l:CLAPACK-3.2.1/libcblaswr.a -l:f2c_BLAS-3.8.0/blas.a -l:libf2c/libf2c.a -L$VOSK/src -l:vosk.a -lopfs.js -lopenal -o $SRC/../asr.js