#include <emscripten/wasmfs.h>
#include <emscripten/console.h>
#include <archive.h>
#include <emscripten.h>
#include <fcntl.h>
#include <archive_entry.h>
#include <string>
void extractModel(const char* filename) {
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
void onerror(const char* filename) {
  emscripten_console_errorf("Couldn't fetch %s", filename);
}
int main() {
  Backend* opfs {wasmfs_create_opfs_backend()};
  wasmfs_create_directory("opfs", 0777, opfs);
  emscripten_async_wget("../model.tzst", "opfs/model.tzst", extractModel, onerror);
}

