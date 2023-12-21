Files inside src are easily read source code. Files outside the src folder are for deployments
#Build guides
*{username} = your Linux username*
Do '''git clone https://github.com/SelftaughtVN/SelftaughtVN.github.io'''
Download emsdk for Emscripten 3.1.51 to home directory, download libarchive 3.7.2 to home directory as "libarchive-3.7.2", follow #2, (coming soon)

#1.Build asr.cpp for emcc
'''
source /home/{username}/emsdk/emsdk_env.sh && em++ asr.cpp -flto=full -O3 -sWASMFS -sWASM_BIGINT -sSUPPORT_BIG_ENDIAN -sPROXY_TO_PTHREAD -pthread -I/home/{username}/libarchive-3.7.2/libarchive -L/home/{username}/libarchive-3.7.2/.libs -larchive -lopfs.js -o asr.js
'''

#2.Building libarchive for the web:
Find and delete the "gc-section" in configure.ac if needed. Then do:
'''
cd /home/{username}/libarchive-3.7.2 && emconfigure ./configure && emmake make -sSIDE_MODULE=1
'''
