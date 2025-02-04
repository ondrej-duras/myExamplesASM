/*
clang -o resdump resdump.c

Dumps res files created by rc.exe.
*/
#include <assert.h>
#include <inttypes.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>
#else
#include <errno.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

static void fatal(const char* msg, ...) {
  va_list args;
  va_start(args, msg);
  vfprintf(stderr, msg, args);
  va_end(args);
  exit(1);
}

static uint32_t read_little_long(unsigned char** d) {
  uint32_t r = ((*d)[3] << 24) | ((*d)[2] << 16) | ((*d)[1] << 8) | (*d)[0];
  *d += sizeof(uint32_t);
  return r;
}

static uint16_t read_little_short(unsigned char** d) {
  uint16_t r = ((*d)[1] << 8) | (*d)[0];
  *d += sizeof(uint16_t);
  return r;
}

// https://msdn.microsoft.com/en-us/library/windows/desktop/ms648009(v=vs.85).aspx
// k prefix so that names don't collide with Win SDK on Windows.
enum {
  kRT_CURSOR = 1,
  kRT_BITMAP = 2,
  kRT_ICON = 3,
  kRT_MENU = 4,
  kRT_DIALOG = 5,
  kRT_STRING = 6,
  kRT_FONTDIR = 7,
  kRT_FONT = 8,
  kRT_ACCELERATOR = 9,
  kRT_RCDATA = 10,
  kRT_MESSAGETABLE = 11,
  kRT_GROUP_CURSOR = 12,
  kRT_GROUP_ICON = 14,
  kRT_VERSION = 16,    // Not stored in image file.
  kRT_DLGINCLUDE = 17,
  kRT_PLUGPLAY = 19,
  kRT_VXD = 20,
  kRT_ANICURSOR = 21,
  kRT_ANIICON = 22,
  kRT_HTML = 23,
  kRT_MANIFEST = 24,
};

static const char* type_str(uint16_t type) {
  switch (type) {
  case 0: return "not 16-bit resource marker";  // First entry only.
  case kRT_CURSOR: return "RT_CURSOR";
  case kRT_BITMAP: return "RT_BITMAP";
  case kRT_ICON: return "RT_ICON";
  case kRT_MENU: return "RT_MENU";
  case kRT_DIALOG: return "RT_DIALOG";
  case kRT_STRING: return "RT_STRING";
  case kRT_FONTDIR: return "RT_FONTDIR";
  case kRT_FONT: return "RT_FONT";
  case kRT_ACCELERATOR: return "RT_ACCELERATOR";
  case kRT_RCDATA: return "RT_RCDATA";
  case kRT_MESSAGETABLE: return "RT_MESSAGETABLE";
  case kRT_GROUP_CURSOR: return "RT_GROUP_CURSOR";
  case kRT_GROUP_ICON: return "RT_GROUP_ICON";
  case kRT_VERSION: return "RT_VERSION";
  case kRT_DLGINCLUDE: return "RT_DLGINCLUDE";
  case kRT_PLUGPLAY: return "RT_PLUGPLAY";
  case kRT_VXD: return "RT_VXD";
  case kRT_ANICURSOR: return "RT_ANICURSOR";
  case kRT_ANIICON: return "RT_ANIICON";
  case kRT_HTML: return "RT_HTML";
  case kRT_MANIFEST: return "RT_MANIFEST";
  default: printf("%x\n", type); assert(0 && "unknown type"); return "unknown";
  }
}

enum WithIdStr { kIdStr, kNoIdStr };
static uint16_t dump_id(
    const char* name, uint8_t** data, enum WithIdStr id_str) {
  uint16_t id = read_little_short(data);
  if (id == 0xffff) {
    id = read_little_short(data);
    if (id_str == kIdStr)
      printf("  %s 0x%" PRIx32 " (%s) ", name, id, type_str(id));
    else
      printf("  %s 0x%" PRIx32 " ", name, id);
    return id;
  } else {
    printf("  %s \"", name);
    while (id != 0) {
      if (id < 128)
        fputc(id, stdout);
      else
        fputc('?', stdout);
      id = read_little_short(data);
    }
    printf("\" ");
    return 0xffff;
  }
}

static void dump_RT_DIALOG_details(uint8_t* data) {
  uint8_t* dialog_start = data;
  uint32_t style = read_little_long(&data);
  printf("  dialog style 0x%" PRIx32 "\n", style);
  uint32_t exstyle = read_little_long(&data);
  printf("  dialog exstyle 0x%" PRIx32 "\n", exstyle);

  uint16_t child_count = read_little_short(&data);
  printf("  control count %d\n", child_count);

  uint16_t x = read_little_short(&data);
  uint16_t y = read_little_short(&data);
  uint16_t w = read_little_short(&data);
  uint16_t h = read_little_short(&data);
  printf("  rect %d %d %d %d\n", x, y, w, h);

  dump_id("menu", &data, kNoIdStr); printf("\n");
  dump_id("class", &data, kNoIdStr); printf("\n");

  // This is a bit of a hack; as far as I know this is always a string,
  // never an ID. But in practice no string starts with 0xffff do dump_id()
  // works.
  dump_id("caption", &data, kNoIdStr); printf("\n");

  if (style & 0x40) {
    uint16_t font_size = read_little_short(&data);
    printf("  font size %d bytes\n", font_size);
    data += font_size;  // XXX dump font name?
  }

  if ((data - dialog_start) % 4)
    data += 2;  // Pad to dword.

  for (int i = 0; i < child_count; ++i) {
    uint8_t* control_start = data;
    uint32_t ctrl_style = read_little_long(&data);
    printf("  control style 0x%" PRIx32 "\n", ctrl_style);
    uint32_t ctrl_exstyle = read_little_long(&data);
    printf("  control exstyle 0x%" PRIx32 "\n", ctrl_exstyle);

    uint16_t ctrl_x = read_little_short(&data);
    uint16_t ctrl_y = read_little_short(&data);
    uint16_t ctrl_w = read_little_short(&data);
    uint16_t ctrl_h = read_little_short(&data);
    printf("  control rect %d %d %d %d\n", ctrl_x, ctrl_y, ctrl_w, ctrl_h);

    uint16_t ctrl_id = read_little_short(&data);
    printf("  control id 0x%x\n", ctrl_id);

    dump_id("control class", &data, kNoIdStr); printf("\n");
    dump_id("control text", &data, kNoIdStr); printf("\n");

    uint16_t ctrl_extradata = read_little_short(&data);
    printf("  %d bytes control extradata\n", ctrl_extradata);
    data += ctrl_extradata;

    if ((data - control_start) % 4)
      data += 2;  // Pad to dword.
  }
}

static size_t dump_resource_entry(uint8_t* data) {
  uint32_t data_size = read_little_long(&data);
  uint32_t header_size = read_little_long(&data);

  printf("Resource Entry, data size 0x%" PRIx32 ", header size 0x%" PRIx32 "\n",
         data_size, header_size);

  if (header_size < 20)
    fatal("header too small");

  // https://msdn.microsoft.com/en-us/library/windows/desktop/ms648027(v=vs.85).aspx

  // if type, name start with 0xffff then they're numeric IDs. Else they're
  // inline zero-terminated utf-16le strings. After name, there might be one
  // word of padding to align data_version.
  uint8_t* string_start = data;
  uint16_t type = dump_id("type", &data, kIdStr);
  dump_id("name", &data, kNoIdStr);
  // Pad to dword boundary:
  if ((data - string_start) & 2)
    data += 2;

  uint32_t data_version = read_little_long(&data);
  uint16_t memory_flags = read_little_short(&data);
  uint16_t language_id = read_little_short(&data);
  uint32_t version = read_little_long(&data);
  uint32_t characteristics = read_little_long(&data);

  printf("dataversion 0x%" PRIx32 "\n", data_version);
  printf("  memflags 0x%" PRIx16 " langid %" PRIu16 " version %" PRIx32 "\n",
         memory_flags, language_id, version);
  printf("  characteristics %" PRIx32 "\n", characteristics);

  if (type == 5)
    dump_RT_DIALOG_details(data);

  uint32_t total_size = data_size + header_size;
  return total_size + ((4 - (total_size & 3)) & 3);  // DWORD-align.
}

int main(int argc, char* argv[]) {
  if (argc != 2)
    fatal("Expected args == 2, got %d\n", argc);

  const char *in_name = argv[1];

  // Read input.
#if defined(_WIN32)
  HANDLE in_file = CreateFile(in_name, GENERIC_READ, FILE_SHARE_READ, NULL,
                              OPEN_EXISTING, FILE_ATTRIBUTE_READONLY, NULL);
  if (in_file == INVALID_HANDLE_VALUE)
    fatal("Unable to read \'%s\'\n", in_name);

  DWORD size = GetFileSize(in_file, NULL);  // 4GB ought to be enough for anyone
  if (size == INVALID_FILE_SIZE)
    fatal("Unable to get file size of \'%s\'\n", in_name);

  HANDLE mapping = CreateFileMapping(in_file, NULL, PAGE_READONLY, 0, 0, NULL);
  if (mapping == NULL)
    fatal("Unable to map \'%s\'\n", in_name);

  uint8_t* data = MapViewOfFile(mapping, FILE_MAP_READ, 0, 0, 0);
  if (data == NULL)
    fatal("Failed to MapViewOfFile: %s\n", in_name);
#else
  int in_file = open(in_name, O_RDONLY);
  if (!in_file)
    fatal("Unable to read \'%s\'\n", in_name);

  struct stat in_stat;
  if (fstat(in_file, &in_stat))
    fatal("Failed to stat \'%s\'\n", in_name);

  size_t size = in_stat.st_size;
  uint8_t* data = mmap(/*addr=*/0, size, PROT_READ, MAP_SHARED, in_file,
                       /*offset=*/0);
  if (data == MAP_FAILED)
    fatal("Failed to mmap: %d (%s)\n", errno, strerror(errno));
#endif

  uint8_t* end = data + size;

  while (data < end) {
    data += dump_resource_entry(data);
  }

#if defined(_WIN32)
  UnmapViewOfFile(data);
  CloseHandle(mapping);
  CloseHandle(in_file);
#else
  munmap(data, in_stat.st_size);
  close(in_file);
#endif
}
