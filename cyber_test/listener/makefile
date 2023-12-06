include ${MAKEFILE_COMMON}

TARGET := listener

OBJDIR   := ./obj
SRCDIR   := ./ ../msg
TARGETDIR = ../../target

# 创建目录,确保目录存在
$(shell mkdir -p ${OBJDIR})
$(shell mkdir -p ${TARGETDIR})

#本模块额外的编译选项
CFLAGS_EXTRA = -std=gnu++14 -I../ -I../../ -I../../cyber

LDFLAGS_EXTRA = -lpthread\
				-lrt\
				-lm\
				-ldl\
				-L../../open_sources/_build/lib -lfastcdr \
				-lfastrtps \
				-lprotobuf \
				-ltinyxml2 \
				-L${TARGETDIR} -lcyber

#这里递归遍历5级子目录
DIRS := $(shell find $(SRCDIR) -maxdepth 5 -type d)
#将每个子目录添加到搜索路径
VPATH = $(DIRS)

## 移远平台需要编译的源码文件，自动搜索和添加所有.cc文件
CPPSOURCES = $(foreach dir, $(VPATH), $(wildcard $(dir)/*.cc))
CPPOBJECTS = $(addprefix $(OBJDIR)/,$(patsubst %.cc,%.o,$(notdir $(filter-out $(FILTERSOURCES),$(CPPSOURCES)))))
DEPENDS = $(CPPOBJECTS:.o=.d)

all: extra_info ${TARGETDIR}/${TARGET}

ifneq ($(MAKECMDGOALS),clean)
-include ${DEPENDS}
endif

define print_lib_info
	@echo -e "${PURPLE_HEAVY}"${INDENT_LAYER2}"linking... " ${TARGETDIR}/${TARGET} "${NO_COLOR}"
endef

${TARGETDIR}/${TARGET}: ${CPPOBJECTS}
	$(call print_lib_info)
	@${CXX} -o $@ ${CPPOBJECTS} ${LDFLAGS_EXTRA} ${LDFLAGS}

#编译之前要创建OBJ目录，确保目录存在

$(OBJDIR)/%.o:%.cc
	$(call print_obj_info)
	@$(CXX) -o $@ -c $< ${CFLAGS_EXTRA} $(CXXFLAGS)

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
	@rm -f $(OBJDIR)/*.o $(OBJDIR)/*.d ${GAC_LIB_PATH}/${TARGET}


