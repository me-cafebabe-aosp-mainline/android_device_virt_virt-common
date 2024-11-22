#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

COMMON_GRUB_PATH := $(VIRT_COMMON_PATH)/bootmgr/grub

ifeq ($(TARGET_BOOT_MANAGER),grub)
ifeq ($(TARGET_GRUB_ARCH),)
$(warning TARGET_GRUB_ARCH is not defined, could not build GRUB)
else
INSTALLED_ESPIMAGE_TARGET_DEPS += \
	$(TARGET_GRUB_BOOT_CONFIGS)

INSTALLED_ESPIMAGE_INSTALL_TARGET_DEPS += \
	$(TARGET_GRUB_INSTALL_CONFIGS)

TARGET_GRUB_HOST_PREBUILT_TAG ?= $(HOST_PREBUILT_TAG)
GRUB_PREBUILT_DIR := prebuilts/bootmgr/grub/$(TARGET_GRUB_HOST_PREBUILT_TAG)/$(TARGET_GRUB_ARCH)

GRUB_WORKDIR_BASE := $(TARGET_OUT_INTERMEDIATES)/GRUB_OBJ
GRUB_WORKDIR_ESP := $(GRUB_WORKDIR_BASE)/esp
GRUB_WORKDIR_INSTALL := $(GRUB_WORKDIR_BASE)/install
GRUB_WORKDIR_PERSIST := $(GRUB_WORKDIR_BASE)/persist

ifeq ($(TARGET_GRUB_ARCH),x86_64-efi)
	GRUB_MKSTANDALONE_FORMAT := x86_64-efi
else
	ifeq ($(TARGET_GRUB_BOOT_EFI_PREBUILT),)
		$(error Please specify prebuilt GRUB EFI file)
	endif
	ifeq ($(TARGET_GRUB_INSTALL_EFI_PREBUILT),)
		$(error Please specify prebuilt GRUB EFI file)
	endif
endif

GRUB_DEFAULT_ENV_VARS_FILE := $(VIRT_COMMON_PATH)/configs/misc/grubenv.txt

# $(1): filesystem root directory
# $(2): path to grub.cfg file
define install-grub-theme
	sed -i "s|@BOOTMGR_THEME@|$(BOOTMGR_THEME)|g" $(2)
	mkdir -p $(1)/boot/grub/themes
	rm -rf $(1)/boot/grub/themes/$(BOOTMGR_THEME)
	$(if $(BOOTMGR_THEME), cp -r $(COMMON_GRUB_PATH)/themes/$(BOOTMGR_THEME) $(1)/boot/grub/themes/)
endef

# $(1): output file
# $(2): files to include
# $(3): workdir
# $(4): purpose (boot or install)
# $(5): configuration files
# $(6): prebuilt EFI file (optional for x86_64-efi)
define make-espimage
	mkdir -p $(3)/fsroot/EFI/BOOT $(3)/fsroot/boot/grub/fonts

	if [ "$(6)" ]; then \
		cp $(6) $(3)/fsroot/EFI/BOOT/$(BOOTMGR_EFI_BOOT_FILENAME); \
	else \
		cp $(COMMON_GRUB_PATH)/grub-standalone.cfg $(3)/grub-standalone.cfg; \
		($(call process-bootmgr-cfg-common,$(3)/grub-standalone.cfg)); \
		sed -i "s|@PURPOSE@|$(4)|g" $(3)/grub-standalone.cfg; \
		$(BOOTMGR_PATH_OVERRIDE) $(GRUB_PREBUILT_DIR)/bin/grub-mkstandalone -d $(GRUB_PREBUILT_DIR)/lib/grub/$(TARGET_GRUB_ARCH) --locales="" --fonts="" --format=$(GRUB_MKSTANDALONE_FORMAT) --output=$(3)/fsroot/EFI/BOOT/$(BOOTMGR_EFI_BOOT_FILENAME) --modules="configfile disk fat part_gpt search" "boot/grub/grub.cfg=$(3)/grub-standalone.cfg"; \
	fi

	cp -r $(GRUB_PREBUILT_DIR)/lib/grub/$(TARGET_GRUB_ARCH) $(3)/fsroot/boot/grub/$(TARGET_GRUB_ARCH)
	cp $(GRUB_PREBUILT_DIR)/share/grub/unicode.pf2 $(3)/fsroot/boot/grub/fonts/unicode.pf2

	touch $(3)/fsroot/boot/grub/.is_esp_part_on_android_$(4)_device

	cat $(5) > $(3)/fsroot/boot/grub/grub.cfg
	$(call process-bootmgr-cfg-common,$(3)/fsroot/boot/grub/grub.cfg)
	$(call install-grub-theme,$(3)/fsroot,$(3)/fsroot/boot/grub/grub.cfg)

	$(if $(filter vboxware,$(TARGET_DEVICE)),\
		sed -i -E 's|(^\| )serial$$||g' $(3)/fsroot/boot/grub/grub.cfg)

	$(call create-fat32image,$(1),$(3)/fsroot/EFI $(3)/fsroot/boot $(2),$(4))
endef

##### espimage #####

# $(1): output file
# $(2): files to include
define make-espimage-target
	$(call pretty,"Target EFI System Partition image: $(1)")
	$(call make-espimage,$(1),$(2),$(GRUB_WORKDIR_ESP),boot,$(TARGET_GRUB_BOOT_CONFIGS),$(TARGET_GRUB_BOOT_EFI_PREBUILT))
endef

##### espimage-install #####

# $(1): output file
# $(2): files to include
define make-espimage-install-target
	$(call pretty,"Target installer ESP image: $(1)")
	$(call make-espimage,$(1),$(2),$(GRUB_WORKDIR_INSTALL),install,$(TARGET_GRUB_INSTALL_CONFIGS),$(TARGET_GRUB_INSTALL_EFI_PREBUILT))
endef

##### isoimage-boot #####

ifeq ($(TARGET_GRUB_ARCH),x86_64-efi)
ifneq ($(LINEAGE_BUILD),)

INSTALLED_ISOIMAGE_BOOT_TARGET := $(PRODUCT_OUT)/$(BOOTMGR_ARTIFACT_FILENAME_PREFIX)-boot.iso
$(INSTALLED_ISOIMAGE_BOOT_TARGET): $(INSTALLED_ESPIMAGE_TARGET) $(TARGET_GRUB_BOOT_CONFIG)
	$(call pretty,"Target boot ISO image: $@")
	$(BOOTMGR_PATH_OVERRIDE) $(GRUB_PREBUILT_DIR)/bin/grub-mkrescue -d $(GRUB_PREBUILT_DIR)/lib/grub/$(TARGET_GRUB_ARCH) --xorriso=$(BOOTMGR_XORRISO_EXEC) -o $@ $(INSTALLED_ESPIMAGE_TARGET_INCLUDE_FILES) $(GRUB_WORKDIR_ESP)/fsroot

.PHONY: isoimage-boot
isoimage-boot: $(INSTALLED_ISOIMAGE_BOOT_TARGET)

endif # LINEAGE_BUILD
endif # TARGET_GRUB_ARCH

##### isoimage-install #####

ifeq ($(TARGET_GRUB_ARCH),x86_64-efi)
ifneq ($(LINEAGE_BUILD),)

INSTALLED_ISOIMAGE_INSTALL_TARGET := $(PRODUCT_OUT)/$(BOOTMGR_ARTIFACT_FILENAME_PREFIX).iso
$(INSTALLED_ISOIMAGE_INSTALL_TARGET): $(INSTALLED_ESPIMAGE_INSTALL_TARGET) $(TARGET_GRUB_INSTALL_CONFIG)
	$(call pretty,"Target installer ISO image: $@")
	$(BOOTMGR_PATH_OVERRIDE) $(GRUB_PREBUILT_DIR)/bin/grub-mkrescue -d $(GRUB_PREBUILT_DIR)/lib/grub/$(TARGET_GRUB_ARCH) --xorriso=$(BOOTMGR_XORRISO_EXEC) -o $@ $(INSTALLED_ESPIMAGE_INSTALL_TARGET_INCLUDE_FILES) $(GRUB_WORKDIR_INSTALL)/fsroot

.PHONY: isoimage-install
isoimage-install: $(INSTALLED_ISOIMAGE_INSTALL_TARGET)

endif # LINEAGE_BUILD
endif # TARGET_GRUB_ARCH

##### persistimage dependencies #####

GRUB_EDITENV_EXEC := $(HOST_OUT_EXECUTABLES)/grub-editenv

INSTALLED_PERSIST_GRUBENV_TARGET := $(GRUB_WORKDIR_PERSIST)/grubenv
$(INSTALLED_PERSIST_GRUBENV_TARGET): $(GRUB_DEFAULT_ENV_VARS_FILE) $(GRUB_EDITENV_EXEC)
	$(hide) mkdir -p $(dir $@)
	$(GRUB_EDITENV_EXEC) $@ create
	$(GRUB_EDITENV_EXEC) $@ set $(shell cat $(GRUB_DEFAULT_ENV_VARS_FILE))

INSTALLED_PERSISTIMAGE_TARGET_DEPS += $(INSTALLED_PERSIST_GRUBENV_TARGET)

ifeq ($(AB_OTA_UPDATER),true)

GRUB_BOOT_CONTROL_EXEC := $(HOST_OUT_EXECUTABLES)/grub_boot_control

INSTALLED_PERSIST_GRUBENV_ABOOTCTRL_TARGET := $(GRUB_WORKDIR_PERSIST)/grubenv_abootctrl
$(INSTALLED_PERSIST_GRUBENV_ABOOTCTRL_TARGET): $(GRUB_BOOT_CONTROL_EXEC)
	$(hide) mkdir -p $(dir $@)
	$(GRUB_BOOT_CONTROL_EXEC) $@

INSTALLED_PERSISTIMAGE_TARGET_DEPS += $(INSTALLED_PERSIST_GRUBENV_ABOOTCTRL_TARGET)

endif # AB_OTA_UPDATER

endif # TARGET_GRUB_ARCH
endif # TARGET_BOOT_MANAGER
