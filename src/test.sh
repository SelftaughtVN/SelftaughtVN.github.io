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

cd $ZSTD && 
rm -rf /tmp/zstd &&
HAVE_THREAD=0 ZSTD_LEGACY_SUPPORT=0 HAVE_ZLIB=0 HAVE_LZMA=0 HAVE_LZ4=0 ZSTD_NOBENCH=1 ZSTD_NODICT=1 ZSTD_NOCOMPRESS=1 BACKTRACE=0 ZSTD_STATIC_LINKING_ONLY=1 PREFIX=/tmp/zstd CPPFLAGS=-O3 LDFLAGS="-O3 -flto=full" emmake make install &&
rm -rf $ZSTD && 
mv /tmp/zstd $ZSTD 