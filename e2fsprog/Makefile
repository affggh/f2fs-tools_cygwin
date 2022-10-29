override CC = clang
override CXX = clang++

CFLAGS = 

INCLUDES = -I./include -I./lib

LIBEXT2_UUID_SRC = \
    lib/uuid/clear.c \
    lib/uuid/compare.c \
    lib/uuid/copy.c \
    lib/uuid/gen_uuid.c \
    lib/uuid/isnull.c \
    lib/uuid/pack.c \
    lib/uuid/parse.c \
    lib/uuid/unpack.c \
    lib/uuid/unparse.c \
    lib/uuid/uuid_time.c
LIBEXT2_UUID_OBJ = $(patsubst %.c,obj/%.o,$(LIBEXT2_UUID_SRC))

obj/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\033[96m\tCC\t$@\033[0m"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

.lib/libext2_uuid.a: $(LIBEXT2_UUID_OBJ)
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