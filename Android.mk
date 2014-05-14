LOCAL_PATH:= $(call my-dir)

# f2fs-tools depends on Linux kernel headers being in the system include path.
ifeq ($(HOST_OS),linux)

# The versions depend on $(LOCAL_PATH)/VERSION
version_CFLAGS := -DF2FS_MAJOR_VERSION=1 -DF2FS_MINOR_VERSION=2 -DF2FS_TOOLS_VERSION=\"1.2.0\" -DF2FS_TOOLS_DATE=\"2013-10-25\"
# external/e2fsprogs/lib is needed for uuid/uuid.h
common_C_INCLUDES := $(LOCAL_PATH)/include external/e2fsprogs/lib/

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	lib/libf2fs.c \
	mkfs/f2fs_format.c \
	mkfs/f2fs_format_utils.c \

LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS)
LOCAL_EXPORT_CFLAGS := $(version_CFLAGS)
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include $(LOCAL_PATH)/mkfs
LOCAL_MODULE := libf2fs_fmt
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	lib/libf2fs.c \
	mkfs/f2fs_format.c \
	mkfs/f2fs_format_utils.c \

LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS)
LOCAL_EXPORT_CFLAGS := $(version_CFLAGS)
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include $(LOCAL_PATH)/mkfs
LOCAL_MODULE := libf2fs_fmt_host
include $(BUILD_HOST_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	lib/libf2fs_io.c \
	mkfs/f2fs_format_main.c \

LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS)
# The LOCAL_MODULE name is referenced by the code. Don't change it.
LOCAL_MODULE := mkfs.f2fs
LOCAL_SHARED_LIBRARIES := libext2_uuid
LOCAL_SYSTEM_SHARED_LIBRARIES := libc
LOCAL_STATIC_LIBRARIES := libf2fs_fmt
LOCAL_MODULE_TAGS := optional
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := \
	fsck/dump.c \
	fsck/fsck.c \
	fsck/main.c \
	fsck/mount.c \
	lib/libf2fs.c \
	lib/libf2fs_io.c \

LOCAL_C_INCLUDES := $(common_C_INCLUDES)
LOCAL_CFLAGS := $(version_CFLAGS)
# The LOCAL_MODULE name is referenced by the code. Don't change it.
LOCAL_MODULE := fsck.f2fs
LOCAL_SHARED_LIBRARIES := libext2_uuid
LOCAL_SYSTEM_SHARED_LIBRARIES := libc
LOCAL_MODULE_TAGS := optional
include $(BUILD_EXECUTABLE)

endif
