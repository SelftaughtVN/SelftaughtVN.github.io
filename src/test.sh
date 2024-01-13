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

# In-place: zstd 1.5.5
cd $ZSTD && 
rm -rf /tmp/zstd &&
HAVE_THREAD=0 ZSTD_LEGACY_SUPPORT=0 HAVE_ZLIB=0 HAVE_LZMA=0 HAVE_LZ4=0 ZSTD_NOBENCH=1 ZSTD_NODICT=1 ZSTD_NOCOMPRESS=1 BACKTRACE=0 ZSTD_STATIC_LINKING_ONLY=1 PREFIX=/tmp/zstd CPPFLAGS="-O3 -flto" LDFLAGS="-O3 -flto" emmake make install &&
rm -rf $ZSTD && 
mv /tmp/zstd $ZSTD &&

# In-place: libarchive 3.7.2
cd $LIBARCHIVE && 
rm -rf /tmp/libarchive &&
build/autogen.sh && 
CPPFLAGS="-I$ZSTD/include -flto" LDFLAGS="-L$ZSTD/lib -flto" emconfigure ./configure --prefix=/tmp/libarchive --without-lz4 --without-lzma --without-zlib --without-bz2lib --without-xml2 --without-expat --without-cng --without-openssl --without-libb2 --disable-bsdunzip --disable-xattr --disable-acl --disable-bsdcpio --disable-bsdcat --disable-rpath --disable-maintainer-mode --disable-dependency-tracking --enable-static --disable-shared && 
emmake make install &&
rm -rf $LIBARCHIVE && 
mv /tmp/libarchive $LIBARCHIVE &&

# clapack-wasm 1.0.0
cd $CLAPACK_WASM &&
bash ./install_repo.sh emcc 