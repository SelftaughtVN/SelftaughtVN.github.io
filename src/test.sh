SRC=$(realpath .) &&
KALDI=$(realpath kaldi) &&
VOSK=$(realpath vosk) &&
OPENFST=$KALDI/tools/openfst &&
LIBARCHIVE=$(realpath libarchive) &&
ZSTD=$(realpath zstd) && 
CLAPACK_WASM=$(realpath clapack-wasm) &&

source ../../emsdk/emsdk_env.sh &&
export PATH=:$PATH:$(realpath ../../emsdk/upstream/bin) &&

#git clone --depth=1 https://github.com/alphacep/openfst /tmp/openfst &&
cd /tmp/openfst &&
autoreconf -i &&
CXXFLAGS="-pthread -r -O3 -flto"  LDFLAGS="-O3 -pthread -flto" emconfigure ./configure --prefix=$OPENFST --enable-static --disable-shared --enable-ngram-fsts --enable-lookahead-fsts --disable-bin --with-pic && 
emmake make install &&

# Quick fake Makefile to bypass Kaldi's openfst version check
echo "PACKAGE_VERSION = 1.8.0" >> $OPENFST/Makefile