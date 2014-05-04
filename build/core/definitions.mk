
###########################################################
## Check to see if ANDROID_BUILD_TOP is set. use absolute
## paths if it is
###########################################################
ifdef ANDROID_BUILD_TOP
$(info ANDROID_BUILD_TOP set using absolute paths)
CLEAR_AUTOTOOLS_VARS:= $(ANDROID_BUILD_TOP)/vendor/*/build/core/clear_autotools_vars.mk
BUILD_AUTOTOOLS:= $(ANDROID_BUILD_TOP)/vendor/*/build/core/autotools.mk
else
$(info ANDROID_BUILD_TOP not set using relative paths)
CLEAR_AUTOTOOLS_VARS:= vendor/*/build/core/clear_autotools_vars.mk
BUILD_AUTOTOOLS:= vendor/*/build/core/autotools.mk
endif


###########################################################
## Adjust GCC Specs to set the apprioate start and end file
## We need to od this because the android toolchain doesn't
## supply it's own sysroot
###########################################################
autotools_gcc_specs:= /tmp/gcc_specs
autotools_gcc_specs_endfile:=%{shared: $(TARGET_CRTEND_SO_O)\;: $(TARGET_CRTEND_O)}
autotools_gcc_specs_startfile:=%{shared: $(TARGET_CRTBEGIN_SO_O);:  %{static: $(TARGET_CRTBEGIN_STATIC_O);:  $(TARGET_CRTBEGIN_DYNAMIC_O)}}

# remove the previous spec file and create a new one
# make sure the directory exists first
# dump specs for our target gcc
# inplace replace the line after endfile definition in the spec file
# use ~ as the delimiter so we don't have to escape the any paths
# inplace replace the line after startfile definition in the spec file
$(autotools_gcc_specs): $(shell rm -f $(autotools_gcc_specs))
	mkdir -p $(dir $(autotools_gcc_specs)) 
	$(TARGET_CC) -dumpspecs > $(autotools_gcc_specs)
	sed -i -r '/\*endfile:/I{n; s~.*~$(autotools_gcc_specs_endfile)~}' $(autotools_gcc_specs)
	sed -i -r '/\*startfile:/I{n; s~.*~$(autotools_gcc_specs_startfile)~}' $(autotools_gcc_specs)


define clear-autotools-vars
autotools_target_ld_static_libraries_paths := 
autotools_target_ld_static_libraries_includes := 
autotools_target_cc_machine :=
autotools_configure_target :=
autotools_configure_host :=
autotools_configure_build := 
autotools_configure_static :=
autotools_configure_shared :=
autotools_configure_enable :=
autotools_configure_disable :=
autotools_configure_with :=
autotools_configure_without := 
autotools_target_sysroot_source :=
autotools_target_sysroot :=
autotools_configure :=
autotools_configure_libexecdir := 
autotools_cpp :=
autotools_cc :=
autotools_gxx :=
autotools_ld :=
autotools_nm :=
autotools_ranlib :=
autotools_strip :=
autotools_ar :=
autotools_gcc_specs_arg :=
autotools_android_config_h := 
autotools_target_sysroot_gcc_lib :=
autotools_cpp_flags := 
autotools_ld_flags := 
autotools_c_flags :=
autotools_cxx_flags :=
autotools_full_cpp :=
autotools_full_cc :=
autotools_full_gxx :=
autotools_full_ld :=
autotools_env_vars_base := 
autotools_configure_env_vars :=
autotools_make_env_vars := 
autotools_make_targets := 
autotools_ltmain :=
autotools_configure_exclude_define := 
endef
