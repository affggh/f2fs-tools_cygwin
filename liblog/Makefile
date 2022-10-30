override CC = clang
override CXX = clang++

CXXFLAGS = \
	-std=c++17 \
	-stdlib=libc++ \
	-D__linux__ \
	-DLIBLOG_LOG_TAG=1006 \
	-DSNET_EVENT_LOG_TAG=1397638484

INCLUDES = \
    -I../libcutils/include \
	-Iinclude \
	-I../base/include \
	-include"deftype.h"

LIBLOG_SRC = \
    log_event_list.cpp \
	log_event_write.cpp \
	logger_name.cpp \
	logger_read.cpp \
	logger_write.cpp \
	logprint.cpp \
	properties.cpp
LIBLOG_OBJ = $(patsubst %.cpp,obj/%.o,$(LIBLOG_SRC))

obj/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\033[96m\tCPP\t$@\033[0m"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

.lib/liblog.a: $(LIBLOG_OBJ)
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