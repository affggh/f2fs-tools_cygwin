override CC = clang
override CXX = clang++

CXXFLAGS = -Doff64_t=off_t -Dftruncate64=ftruncate -Dlseek64=lseek -stdlib=libc++ -std=c++17 -Wno-macro-redefined -static

INCLUDES = -I./include -I../base/include -I../zlib

LIBSPARSE_SRC = \
    backed_block.cpp \
    output_file.cpp \
    sparse.cpp \
    sparse_crc32.cpp \
    sparse_err.cpp \
    sparse_read.cpp 
LIBSPARSE_OBJ = $(patsubst %.cpp,obj/%.o,$(LIBSPARSE_SRC))

obj/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\033[96m\tCC\t$@\033[0m"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

.lib/libsparse.a: $(LIBSPARSE_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\033[93m\tAR\t$@\033[0m"
	@$(AR) rcs $@ $^

clean:
ifeq ($(shell [[ -d "obj" ]];echo $$?), 0)
	@echo -e "\033[93m\tRM\tobj\033[0m"
	@rm -rf obj
endif
ifeq ($(shell [[ -d ".lib" ]];echo $$?), 0)
	@echo -e "\033[93m\tRM\t.lib\033[0m"
	@rm -rf .lib
endif