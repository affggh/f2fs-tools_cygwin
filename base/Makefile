override CC = clang
override CXX = clang++

CXXFLAGS = -std=c++17 -stdlib=libc++ -Wall -D_FILE_OFFSET_BITS=64 -D__linux__ -D__CYGWIN__ -Wextra -static

INCLUDES = -I../liblog/include -I./include

LIBBASE_SRC = \
    abi_compatibility.cpp \
    chrono_utils.cpp \
    cmsg.cpp \
    file.cpp \
    liblog_symbols.cpp \
    logging.cpp \
    mapped_file.cpp \
    parsebool.cpp \
    parsenetaddress.cpp \
    process.cpp \
    properties.cpp \
    stringprintf.cpp \
    strings.cpp \
    threads.cpp \
    test_utils.cpp \
    errors_unix.cpp
LIBBASE_OBJ = $(patsubst %.cpp,obj/%.o,$(LIBBASE_SRC))

obj/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\033[96m\tCPP\t$@\033[0m"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

.lib/libbase.a: $(LIBBASE_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\033[93m\tAR\t$@\033[0m"
	@$(AR) rcs $@ $^

.lib/libbase.dll: $(LIBBASE_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\033[93m\tLD\t$@\033[0m"
	@$(CXX) $(CXXFLAGS) $(INCLIDES) -shared $< -o $@

clean:
ifeq ($(shell [[ -d "obj" ]];echo $$?), 0)
	@echo -e "\033[93m\tRM\tobj\033[0m"
	@rm -rf obj
endif
ifeq ($(shell [[ -d ".lib" ]];echo $$?), 0)
	@echo -e "\033[93m\tRM\t.lib\033[0m"
	@rm -rf .lib
endif

