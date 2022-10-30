override CC = clang
override CXX = clang++

CXXFLAGS = -stdlib=libc++ -D_GNU_SOURCE

INCLUDES = -I./include -I../base/include -I../liblog/include

LIBCUTILS_SRC = \
    hashmap.cpp \
    multiuser.cpp \
    ashmem-host.cpp \
    config_utils.cpp \
    canned_fs_config.cpp \
    iosched_policy.cpp \
    load_file.cpp \
    native_handle.cpp \
    record_stream.cpp \
    strlcpy.c \
    fs_config.cpp \
    threads.cpp 
LIBCUTILS_OBJ = $(patsubst %.cpp,obj/%.o,$(LIBCUTILS_SRC))

obj/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\033[94m\tCPP\t$@\033[0m"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

.lib/libcutils.a: $(LIBCUTILS_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\033[94m\tAR\t$@\033[0m"
	@$(AR) rcs $@ $^

.lib/libcutils.dll: $(LIBCUTILS_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\033[94m\tLD\t$@\033[0m"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -shared -o $@ $^ ../base/.lib/libbase.a

clean:
ifeq ($(shell [[ -d "obj" ]];echo $$?), 0)
	@echo -e "\033[94m\tRM\tobj\033[0m"
	@rm -rf obj
endif
ifeq ($(shell [[ -d ".lib" ]];echo $$?), 0)
	@echo -e "\033[94m\tRM\t.lib\033[0m"
	@rm -rf .lib
endif