#include <emscripten/wasmfs.h>
#include <emscripten/console.h>
#include <emscripten.h>
#include <archive.h>
#include <archive_entry.h>
#include <string>
#include <filesystem>
namespace fs = std::filesystem;
void extract(const char* filename) {
  std::string path{"opfs/"};
  archive* src {archive_read_new()};
  archive_entry* entry {};
  archive_read_support_filter_all(src);
  archive_read_support_format_all(src);
  archive_read_open_filename(src,filename,10240);
  while (archive_read_next_header(src, &entry) == ARCHIVE_OK) {
    path+= archive_entry_pathname(entry);
    archive_entry_set_pathname(entry, path.c_str());
    path="opfs/";
    archive_read_extract(src, entry, ARCHIVE_EXTRACT_UNLINK);
  }
  archive_read_free(src);
}
int main() {
  pthread_t pt {};
  pthread_create(&pt, nullptr, [](void* dummy) -> void*{
    pthread_detach(pthread_self());
    Backend* opfs {wasmfs_create_opfs_backend()};
    wasmfs_create_directory("opfs", 0777, opfs);
    if(!(fs::exists("opfs/model/am/final.mdl") &&
    fs::exists("opfs/model/conf/mfcc.conf") &&
    fs::exists("opfs/model/conf/model.conf") &&
    fs::exists("opfs/model/graph/phones/word_boundary.int") &&
    fs::exists("opfs/model/graph/Gr.fst") &&
    fs::exists("opfs/model/graph/HCLr.fst") &&
    fs::exists("opfs/model/graph/disambig_tid.int") &&
    fs::exists("opfs/model/ivector/final.dubm") &&
    fs::exists("opfs/model/ivector/final.ie") &&
    fs::exists("opfs/model/ivector/final.mat") &&
    fs::exists("opfs/model/ivector/global_cmvn.stats") &&
    fs::exists("opfs/model/ivector/online_cmvn.conf") &&
    fs::exists("opfs/model/ivector/splice.conf"))) {
      emscripten_async_wget("../model.tzst", "opfs/model.tzst", extract, [](const char* filename){
        emscripten_console_errorf("Couldn't fetch %s", filename);
      });
    }
    fs::remove("opfs/model.tzst"); //Remove if possible, see https://github.com/emscripten-core/emscripten/issues/20977
    return nullptr;
  },nullptr);
}