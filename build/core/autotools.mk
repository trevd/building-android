
$(call $(clear-autotools-vars))
TARGET_OUT_AUTOTOOLS := $(PRODUCT_OUT)/autotools
LOCAL_MODULE_CLASS := AUTOTOOLS
LOCAL_MODULE_SUFFIX := -autotools

include build/core/base_rules.mk

autotools_target_ld_static_libraries_paths := $(addprefix -L$(PRODUCT_OUT)/STATIC_LIBRARIES/,$(LOCAL_STATIC_LIBRARIES))
autotools_target_ld_static_libraries_paths := $(addsuffix _intermediates,$(autotools_target_ld_static_libraries_paths))
autotools_target_ld_static_libraries_includes := $(addprefix -l:,$(LOCAL_STATIC_LIBRARIES))
autotools_target_ld_static_libraries_includes := $(addsuffix .a,$(autotools_target_ld_static_libraries_includes))
autotools_target_cc_machine :=$(or $(LOCAL_CONFIGURE_TARGET),$(shell $(TARGET_CC) -dumpmachine))

ifeq ($(strip $(LOCAL_CONFIGURE_NO_TARGET)),true)
autotools_configure_target :=
else
autotools_configure_target :=  --target=$(autotools_target_cc_machine) 
endif
ifeq ($(strip $(LOCAL_CONFIGURE_NO_HOST)),true)
autotools_configure_host := 
else
autotools_configure_host := --host=$(or $(LOCAL_CONFIGURE_HOST),$(shell $(TARGET_CC) -dumpmachine))
endif
ifeq ($(strip $(LOCAL_CONFIGURE_NO_BUILD)),true)
autotools_configure_build := 
else
autotools_configure_build := --build=$(or $(LOCAL_CONFIGURE_BUILD),$(shell $(HOST_CC) -dumpmachine))
endif

autotools_configure_static := $(if $(strip $(LOCAL_CONFIGURE_STATIC)),--$(subst true,enable,$(subst false,disable,$(strip $(LOCAL_CONFIGURE_STATIC))))-static)
autotools_configure_shared := $(if $(strip $(LOCAL_CONFIGURE_SHARED)),--$(subst true,enable,$(subst false,disable,$(strip $(LOCAL_CONFIGURE_SHARED))))-shared)
autotools_configure_enable := $(if $(strip $(LOCAL_CONFIGURE_ENABLE)),$(addprefix --enable-,$(strip $(LOCAL_CONFIGURE_ENABLE))))
autotools_configure_disable := $(if $(strip $(LOCAL_CONFIGURE_DISABLE)),$(addprefix --disable-,$(strip $(LOCAL_CONFIGURE_DISABLE))))
autotools_configure_with := $(if $(strip $(LOCAL_CONFIGURE_WITH)),$(addprefix --with-,$(strip $(LOCAL_CONFIGURE_WITH))))
autotools_configure_without := $(if $(strip $(LOCAL_CONFIGURE_WITHOUT)),$(addprefix --without-,$(strip $(LOCAL_CONFIGURE_WITHOUT))))


autotools_target_sysroot_source :=  $(addprefix $(ANDROID_BUILD_TOP)/,$(subst $(ANDROID_BUILD_TOP)/,,$(TARGET_TOOLCHAIN_ROOT)))
autotools_target_sysroot :=  /tmp/sysroot
autotools_configure :=  $(addprefix $(ANDROID_BUILD_TOP)/,$(subst $(ANDROID_BUILD_TOP)/,,$(LOCAL_PATH)))/configure

ifeq ($(strip $(LOCAL_CONFIGURE_NO_LIBEXECDIR)),true)
autotools_configure_libexecdir := 
else
autotools_configure_libexecdir := --libexec=$(or $(LOCAL_CONFIGURE_LIBEXECDIR),$(autotools_target_sysroot)/libexec)
endif

autotools_cpp := $(autotools_target_sysroot)/bin/$(autotools_target_cc_machine)-cpp
autotools_cc := $(autotools_target_sysroot)/bin/$(autotools_target_cc_machine)-gcc
autotools_gxx := $(autotools_target_sysroot)/bin/$(autotools_target_cc_machine)-g++
autotools_ld := $(autotools_target_sysroot)/bin/$(autotools_target_cc_machine)-ld
autotools_nm := $(autotools_target_sysroot)/bin/$(autotools_target_cc_machine)-nm
autotools_ranlib := $(autotools_target_sysroot)/bin/$(autotools_target_cc_machine)-ranlib
autotools_strip := $(autotools_target_sysroot)/bin/$(autotools_target_cc_machine)-strip
autotools_ar := $(autotools_target_sysroot)/bin/$(autotools_target_cc_machine)-ar
autotools_gcc_specs_arg := --specs=$(autotools_gcc_specs)

autotools_android_config_h := $(intermediates)/AndroidConfig.h

autotools_target_sysroot_gcc_lib := $(autotools_target_sysroot)/lib/gcc/$(autotools_target_cc_machine)/$(TARGET_GCC_VERSION)
autotools_cpp_flags := -mandroid -nostdinc -include $(local-intermediates-dir)/AndroidConfig.h
autotools_cpp_flags += -I$(local-intermediates-dir)/include $(addprefix -I $(ANDROID_BUILD_TOP)/,$(LOCAL_C_INCLUDES))
autotools_cpp_flags += -U_GNU_SOURCE
autotools_cpp_flags += -I$(autotools_target_sysroot_gcc_lib)/include-fixed
autotools_cpp_flags += -I$(autotools_target_sysroot_gcc_lib)/include 
autotools_cpp_flags += -I$(autotools_target_sysroot)/include
autotools_cpp_flags += -I$(PRODUCT_OUT)/system/include 
autotools_cpp_flags += $(LOCAL_CFLAGS)
autotools_cpp_flags += $(addprefix -isystem $(ANDROID_BUILD_TOP)/,$(TARGET_C_INCLUDES) $(filter-out $(TARGET_OUT_HEADERS),$(TARGET_PROJECT_INCLUDES))) 
		

autotools_ld_flags := -mbionic $(TARGET_GLOBAL_LD_DIRS) 
autotools_ld_flags += $(autotools_target_ld_static_libraries_paths)
autotools_ld_flags += $(TARGET_GLOBAL_LDFLAGS) 
autotools_ld_flags += -L$(PRODUCT_OUT)/system/lib
autotools_ld_flags += $(addprefix -L,$(LOCAL_LD_DIRS))
autotools_ld_flags += $(LOCAL_LDFLAGS)
autotools_ld_flags := $(subst -Wl$(comma)--icf=safe,,$(autotools_ld_flags))
autotools_ld_flags := $(subst -Wl$(comma)--fix-cortex-a8,,$(autotools_ld_flags))



autotools_c_flags := $(subst $(android_config_h),,$(TARGET_GLOBAL_CFLAGS))
autotools_c_flags := $(autotools_ld_flags)
autotools_c_flags := $(subst $(ANDROID_BUILD_TOP)/build,build,$(autotools_c_flags))
autotools_c_flags := $(autotools_cpp_flags) $(subst -I build,-I $(ANDROID_BUILD_TOP)/build,$(autotools_c_flags))

autotools_cxx_flags := $(TARGET_GLOBAL_CXXFLAGS)  $(autotools_c_flags)
autotools_ld_flags += $(autotools_gcc_specs_arg) 

autotools_full_cpp := $(autotools_cpp) $(autotools_cpp_flags)
autotools_full_cc := $(autotools_cc) $(autotools_gcc_specs_arg)
autotools_full_gxx := $(autotools_gxx) $(autotools_gcc_specs_arg)
autotools_full_ld := $(autotools_ld) $(autotools_gcc_specs_arg) 

autotools_env_vars_base := \
							CPP="$(autotools_full_cpp)" \
							CC="$(autotools_full_cc)" \
							CXX="$(autotools_full_gxx)" \
							LD="$(autotools_ld)" \
							AR="$(autotools_ar)" \
							NM="$(autotools_nm)" \
							RANLIB="$(autotools_ranlib)" \
							STRIP="$(autotools_strip)" \
							CFLAGS="-std=c11 --sysroot=$(autotools_target_sysroot) $(autotools_c_flags)" \
							CPPFLAGS="-std=c11 $(autotools_cpp_flags)" \
							CXXFLAGS="$(autotools_cxx_flags)" \
						
							
autotools_configure_env_vars := $(autotools_env_vars_base) LDFLAGS="$(autotools_ld_flags)"							
autotools_make_env_vars := $(autotools_env_vars_base) LDFLAGS="-avoid_version $(autotools_ld_flags)"

autotools_make_targets := $(addprefix && \
							 $(autotools_make_env_vars) $(MAKE) $(LOCAL_MAKE_ADDITIONAL_ARGUMENTS) DESTDIR=$(PRODUCT_OUT) ,\
							 $(or $(LOCAL_CONFIGURE_MAKE_TARGETS),all))


autotools_ltmain := $(if $(strip $(realpath $(LOCAL_PATH)/ltmain.sh)),sed -i 's~avoid_version=no~avoid_version=yes~g' $(LOCAL_PATH)/ltmain.sh)

autotools_configure_exclude_define := $(foreach exclude_define,$(LOCAL_CONFIGURE_EXCLUDE_DEFINE),&& sed -i 's~\#define $(exclude_define)~//~g' $(autotools_android_config_h))

$(LOCAL_BUILT_MODULE): $(autotools_gcc_specs) $(TARGET_CRTBEGIN_SO_O) $(TARGET_CRTBEGIN_STATIC_O)  $(TARGET_CRTBEGIN_DYNAMIC_O)
	$(hide) echo "Autotools: $@"
	$(hide) echo "Autotools: Target 			: $(autotools_configure_target)"
	$(hide) echo "Autotools: Host				: $(autotools_configure_host)"
	$(hide) echo "Autotools: Build			: $(autotools_configure_build)"
	$(hide) echo "Autotools: Sysroot 			: $(autotools_target_sysroot)"
	$(hide) echo "Autotools: Sysroot GCC LIB 		: $(autotools_target_sysroot_gcc_lib)"
	$(hide) echo "Autotools: configure 			: $(autotools_configure)"
	$(hide) echo "Autotools: configure static		: $(autotools_configure_static)"
	$(hide) echo "Autotools: configure shared		: $(autotools_configure_shared)"
	$(hide) echo "Autotools: configure with		: $(autotools_configure_with)"
	$(hide) echo "Autotools: configure without		: $(autotools_configure_without)"
	$(hide) echo "Autotools: configure enable		: $(autotools_configure_enable)"
	$(hide) echo "Autotools: configure disable		: $(autotools_configure_disable)"
	$(hide) echo "Autotools: cpp 				: $(autotools_cpp)"
	$(hide) echo "Autotools: cc 				: $(autotools_cc)"
	$(hide) echo "Autotools: gxx 				: $(autotools_gxx)"
	$(hide) echo "Autotools: ld 				: $(autotools_ld)"
	$(hide) echo "Autotools: cpp flags			: $(autotools_cpp_flags)"
	$(hide) echo "Autotools: c flags			: $(autotools_c_flags)"
	$(hide) echo "Autotools: ld flags			: $(autotools_ld_flags)"
	$(hide) echo "Autotools: gcc specs			: $(autotools_gcc_specs_arg)"
	$(hide) echo "Autotools: make targets		: $(autotools_make_targets)"
	$(hide) echo "Autotools: autotools_configure_env_vars		: $(autotools_configure_env_vars)"
	$(hide) rm -rf $@
	$(hide) mkdir -p $@
	$(hide) ln -sf $(autotools_target_sysroot_source) $(autotools_target_sysroot)
	$(hide) cp $(android_config_h) $(autotools_android_config_h)
	$(hide) $(autotools_ltmain)
	$(hide) cd $@ && \
	$(autotools_configure_env_vars) \
	$(autotools_configure) \
	$(autotools_configure_target) $(autotools_configure_host) $(autotools_configure_build) \
	$(autotools_configure_disable) $(autotools_configure_enable) \
	$(autotools_configure_without) $(autotools_configure_with) \
	$(autotools_configure_shared) $(autotools_configure_static) \
	$(LOCAL_CONFIGURE_ADDITIONAL_ARGUMENTS) \
	--prefix=/system \
		--bindir=/system/bin \
		--libdir=/system/lib \
		$(autotools_configure_libexecdir) \
	$(autotools_configure_exclude_define) \
	$(autotools_make_targets) \
	&& $(MAKE) install DESTDIR=$(PRODUCT_OUT)
	$(hide) rm -f $(PRODUCT_OUT)/system/lib/*.la
	$(hide) touch $@
