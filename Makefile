# Makefile write by affggh
# Under GPLv2 Licenses

CC = clang
CXX = clang++
STRIP = strip
AR = ar

RM = rm -rf

SHELL = bash

ifeq ($(shell uname -o), Cygwin)
EXT = .exe
else
EXT = 
endif

CFLAGS = \
        -DF2FS_MAJOR_VERSION=1 \
        -DF2FS_MINOR_VERSION=15 \
        -DF2FS_TOOLS_VERSION=\"1.15.0\" \
        -DF2FS_TOOLS_DATE=\"2022-05-20\" \
        -DWITH_ANDROID \
        -Wall \
        -Werror \
        -Wno-macro-redefined \
        -Wno-missing-field-initializers \
        -Wno-pointer-arith \
        -Wno-sign-compare

ifeq ($(shell uname -o), Cygwin)
# Should I use -D_WIN32 and -DANDROID_WINDOWS_HOST ?
CFLAGS += \
		  -Doff64_t=off_t \
#          -Dlseek64=lseek 

endif

CXXFLAGS = \
        -std=c++17 -stdlib=libc++

INCLUDES = -Iinclude \
        -Imkfs \
        -Ifsck \
		-Ie2fsprog/lib \
		-Ilibselinux/include \
		-Ilibcutils/include \
		-Ilz4/lib -Izlib
ifeq ($(shell uname -o), Cygwin)
INCLUDES += -include /usr/include/limits.h
endif

LDFLAGS = -lstdc++ -static
STRIPFLAGS = --strip-all

LIBF2FS_SRC = \
        lib/libf2fs.c \
        mkfs/f2fs_format.c \
        mkfs/f2fs_format_utils.c \
        lib/libf2fs_zoned.c \
        lib/nls_utf8.c
LIBF2FS_OBJ = $(patsubst %.c,obj/libf2fs/%.o,$(LIBF2FS_SRC))

MAKE_F2FS_SRC = \
        lib/libf2fs_io.c \
        mkfs/f2fs_format_main.c
MAKE_F2FS_OBJ = $(patsubst %.c,obj/makef2fs/%.o,$(MAKE_F2FS_SRC))

FSCK_MAIN_F2FS_SRC = \
        fsck/dir.c \
        fsck/dict.c \
        fsck/mkquota.c \
        fsck/quotaio.c \
        fsck/quotaio_tree.c \
        fsck/quotaio_v2.c \
        fsck/node.c \
        fsck/segment.c \
        fsck/xattr.c \
        fsck/main.c \
        fsck/mount.c \
        lib/libf2fs.c \
        lib/libf2fs_io.c \
        lib/libf2fs_zoned.c \
        lib/nls_utf8.c \
        fsck/dump.c
FSCK_MAIN_F2FS_OBJ = $(patsubst %.c,obj/sloadf2fs/%.o,$(FSCK_MAIN_F2FS_SRC))

FSCK_F2FS_SRC = $(FSCK_MAIN_F2FS_SRC) fsck/fsck.c fsck/resize.c fsck/defrag.c
FSCK_F2FS_OBJ = $(patsubst %.c,obj/fsckf2fs/%.o,$(FSCK_F2FS_SRC))

SLOAD_F2FS_SRC = \
        fsck/fsck.c \
        fsck/sload.c \
        fsck/compress.c
SLOAD_F2FS_OBJ = $(patsubst %.c,obj/sloadf2fs/%.o,$(SLOAD_F2FS_SRC))

ZLIB_CFLAGS = \
        -DHAVE_HIDDEN \
        -DZLIB_CONST \
        -O3 \
        -Wall \
        -Werror \
        -Wno-unused \
        -Wno-unused-parameter
ZLIB_SRC = zlib/adler32.c \
        zlib/adler32_simd.c \
        zlib/compress.c \
        zlib/cpu_features.c \
        zlib/crc32.c \
        zlib/crc32_simd.c \
        zlib/crc_folding.c \
        zlib/deflate.c \
        zlib/gzclose.c \
        zlib/gzlib.c \
        zlib/gzread.c \
        zlib/gzwrite.c \
        zlib/infback.c \
        zlib/inffast.c \
        zlib/inflate.c \
        zlib/inftrees.c \
        zlib/trees.c \
        zlib/uncompr.c \
        zlib/zutil.c
ZLIB_OBJ = $(patsubst %.c,obj/zlib/%.o,$(ZLIB_SRC))

TARGETS = bin/make_f2fs$(EXT) bin/sload_f2fs$(EXT) bin/fsck.f2fs$(EXT)
ifeq ($(shell uname -o), Cygwin)
TARGETS += bin/cygwin1.dll
endif

.PHONY: all

all: $(TARGETS)

obj/libf2fs/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\033[96m\tCC\t$@\033[0m"
	@$(CC) $(CFLAGS) -DWITH_BLKDISCARD $(INCLUDES) -c $< -o $@

obj/makef2fs/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\033[96m\tCC\t$@\033[0m"
	@$(CC) $(CFLAGS) -DWITH_BLKDISCARD -Isparse/include $(INCLUDES) -c $< -o $@

obj/sloadf2fs/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\033[96m\tCC\t$@\033[0m"
	@$(CC) $(CFLAGS) $(INCLUDES) -DWITH_SLOAD -Wno-char-subscripts -Isparse/include -c $< -o $@

obj/fsckf2fs/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\033[96m\tCC\t$@\033[0m"
	@$(CC) $(CFLAGS) $(INCLUDES) -DWITH_RESIZE -DWITH_DEFRAG -DWITH_DUMP -Wno-char-subscripts -Isparse/include -c $< -o $@

obj/zlib/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\033[96m\tCC\t$@\033[0m"
	@$(CC) $(ZLIB_CFLAGS) -Izlib -c $< -o $@

e2fsprog/.lib/libext2_uuid.a:
	@$(MAKE) -C e2fsprog

base/.lib/libbase.a:
	@$(MAKE) -C base

sparse/.lib/libsparse.a:
	@$(MAKE) -C sparse

liblog/.lib/liblog.a:
	@$(MAKE) -C liblog

libselinux/.lib/libselinux.a:
	@$(MAKE) -C libselinux

libcutils/.lib/libcutils.a:
	@$(MAKE) -C libcutils

# I faced issue defination like DWORD and etc
# and failed at final link...
# issue solution at https://github.com/openssl/openssl/issues/19531
openssl/libcrypto.a:
	@cd openssl && ./Configure && $(MAKE) -j$(shell nproc --all)

lz4/lib/liblz4.a:
	@$(MAKE) -C lz4 lib

obj/.lib/libz.a: $(ZLIB_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\033[93m\tAR\t$@\033[0m"
	@$(AR) rcs $@ $^

obj/.lib/libf2fs_fmt.a: $(LIBF2FS_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\033[93m\tAR\t$@\033[0m"
	@$(AR) rcs $@ $^

bin/make_f2fs$(EXT): $(MAKE_F2FS_OBJ) \
                     obj/.lib/libf2fs_fmt.a \
					 e2fsprog/.lib/libext2_uuid.a \
					 sparse/.lib/libsparse.a \
					 base/.lib/libbase.a \
					 liblog/.lib/liblog.a \
					 obj/.lib/libz.a
	@mkdir -p `dirname $@`
	@echo -e "\033[95m\tLD\t$@\033[0m"
	@$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)
	@echo -e "\033[95m\tSTRIP\t$@\033[0m"
	@$(STRIP) $(STRIPFLAGS) $@

# 					 openssl/libcrypto.a
bin/sload_f2fs$(EXT): $(SLOAD_F2FS_OBJ) $(FSCK_MAIN_F2FS_OBJ) \
					 e2fsprog/.lib/libext2_uuid.a \
					 sparse/.lib/libsparse.a \
					 base/.lib/libbase.a \
					 libselinux/.lib/libselinux.a \
					 libcutils/.lib/libcutils.a \
					 liblog/.lib/liblog.a \
					 lz4/lib/liblz4.a \
					 obj/.lib/libz.a
	@mkdir -p `dirname $@`
	@echo -e "\033[95m\tLD\t$@\033[0m"
	@$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)
	@echo -e "\033[95m\tSTRIP\t$@\033[0m"
	@$(STRIP) $(STRIPFLAGS) $@

bin/fsck.f2fs$(EXT): $(FSCK_F2FS_OBJ) \
					 obj/.lib/libf2fs_fmt.a \
					 e2fsprog/.lib/libext2_uuid.a \
					 sparse/.lib/libsparse.a \
					 base/.lib/libbase.a \
					 obj/.lib/libz.a
	@mkdir -p `dirname $@`
	@echo -e "\033[95m\tLD\t$@\033[0m"
	@$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)
	@echo -e "\033[95m\tSTRIP\t$@\033[0m"
	@$(STRIP) $(STRIPFLAGS) $@		 

bin/cygwin1.dll:
	@mkdir `dirname $@`
	@echo -e "\033[96m\tCOPY\t`which cygwin1.dll` => $@\t\033[0m"
	@cp -f `which cygwin1.dll` $@

clean:
ifeq ($(shell [[ -d "obj" ]];echo $$?), 0)
	@echo -e "\033[93m\tRM\tobj\033[0m"
	@rm -rf obj
endif
ifeq ($(shell [[ -d "bin" ]];echo $$?), 0)
	@echo -e "\033[93m\tRM\tbin\033[0m"
	@rm -rf bin
endif
	@$(MAKE) -C e2fsprog clean
	@$(MAKE) -C base clean
	@$(MAKE) -C sparse clean
	@$(MAKE) -C libselinux clean
	@$(MAKE) -C libcutils clean
ifeq ($(shell [[ -f "openssl/Makefile" ]];echo $$?), 0)
#	@$(MAKE) -C openssl clean
endif
	@$(MAKE) -C lz4 clean
	@find . -type f -name *.o | xargs $(RM)
