include ./makefile_common.mk

TARGET := libcyber.so

OBJDIR   := ./obj
SRCDIR   := ./cyber
TARGETDIR = ./target

# 创建目录,确保目录存在
$(shell mkdir -p ${OBJDIR})
$(shell mkdir -p ${TARGETDIR})

#本模块额外的编译选项
CFLAGS_EXTRA = -std=gnu++14 -I./ -I./cyber -I./open_sources/_build/include

LDFLAGS_EXTRA = -shared\
				-lpthread\
				-lrt\
				-lm\
				-ldl\
				-luuid \
				-latomic \
				-L./open_sources/_build/lib -lfastcdr \
				-lfastrtps \
				-lprotobuf

#这里递归遍历5级子目录
DIRS := $(shell find $(SRCDIR) -maxdepth 5 -type d)
#将每个子目录添加到搜索路径
VPATH = $(DIRS)

## 移远平台需要编译的源码文件，自动搜索和添加所有.cc文件
CPPSOURCES = $(foreach dir, $(VPATH), $(wildcard $(dir)/*.cc))
S_SOURCES += $(foreach dir, $(VPATH), $(wildcard $(dir)/*.S))
CPPOBJECTS = $(addprefix $(OBJDIR)/,$(patsubst %.cc,%.o,$(notdir $(filter-out $(FILTERSOURCES),$(CPPSOURCES)))))
S_OBJECTS   = $(addprefix $(OBJDIR)/,$(patsubst %.S,%.o,$(notdir $(filter-out $(FILTERSOURCES),$(S_SOURCES)))))
DEPENDS = $(CPPOBJECTS:.o=.d)

define print_lib_info
	@echo -e "${PURPLE_HEAVY}"${INDENT_LAYER2}"linking... " ${TARGETDIR}/${TARGET} "${NO_COLOR}"
endef

all: extra_info ${TARGETDIR}/${TARGET}

ifneq ($(MAKECMDGOALS),clean)
-include ${DEPENDS}
endif

${TARGETDIR}/${TARGET}: ${CPPOBJECTS} ${S_OBJECTS}
	$(call print_lib_info)
	@${CXX} -o $@ ${CPPOBJECTS} ${S_OBJECTS}  ${LDFLAGS_EXTRA} ${LDFLAGS}

#编译之前要创建OBJ目录，确保目录存在

$(OBJDIR)/%.o:%.cc
	$(call print_obj_info)
	@$(CXX) -o $@ -c $< ${CFLAGS_EXTRA} $(CXXFLAGS)

## cyber有个汇编语言文件，一定要编译进来
$(OBJDIR)/%.o:%.S
	$(call print_obj_info)
	@$(CC) -o $@ -c $< ${CFLAGS}

${OBJDIR}/%.d:%.cc
	@rm -f $@
	@${CXX} -MM $< > $@.temp ${CFLAGS_EXTRA} ${CXXFLAGS}
	@sed 's,\($*\)\.o[:]*,${OBJDIR}/\1.o $@:,g' < $@.temp >$@
	@rm -rf $@.temp

.PHONY : extra_info clean
extra_info:
	$(call print_compiler_exter_info)

clean:
	$(call print_clean_lib_info)
	@rm -f $(OBJDIR)/*.o $(OBJDIR)/*.d ${TARGETDIR}/${TARGET}

