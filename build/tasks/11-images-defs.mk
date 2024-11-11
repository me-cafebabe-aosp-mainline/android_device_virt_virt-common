#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(USES_DEVICE_VIRT_VIRT_COMMON),true)

##### Installation image #####
ifneq ($(TARGET_BOOT_MANAGER),)
INSTALLED_ESPIMAGE_INSTALL_TARGET := $(PRODUCT_OUT)/$(BOOTMGR_ARTIFACT_FILENAME_PREFIX).img

INSTALLED_ESPIMAGE_INSTALL_TARGET_INCLUDE_FILES := \
	$(PRODUCT_OUT)/kernel \
	$(INSTALLED_COMBINED_RAMDISK_RECOVERY_TARGET) \
	$(PRODUCT_OUT)/$(BOOTMGR_ANDROID_OTA_PACKAGE_NAME)

INSTALLED_ESPIMAGE_INSTALL_TARGET_DEPS := \
	$(INSTALLED_ESPIMAGE_INSTALL_TARGET_INCLUDE_FILES)
endif

##### EFI #####
ifneq ($(TARGET_BOOT_MANAGER),)
INSTALLED_ESPIMAGE_TARGET_INCLUDE_FILES :=
ifneq ($(AB_OTA_UPDATER),true)
INSTALLED_ESPIMAGE_TARGET_INCLUDE_FILES += \
	$(PRODUCT_OUT)/kernel \
	$(INSTALLED_COMBINED_RAMDISK_TARGET) \
	$(INSTALLED_COMBINED_RAMDISK_RECOVERY_TARGET)
endif

# Note: bootmgr configs are added only to DEPS, not to INCLUDE_FILES
INSTALLED_ESPIMAGE_TARGET_DEPS := \
	$(INSTALLED_ESPIMAGE_TARGET_INCLUDE_FILES)
endif # TARGET_BOOT_MANAGER

##### grub_boot #####
ifeq ($(AB_OTA_UPDATER),true)
ifeq ($(TARGET_BOOT_MANAGER),grub)
INSTALLED_GRUB_BOOT_IMAGE_TARGET_DEPS := \
	$(PRODUCT_OUT)/kernel \
	$(INSTALLED_COMBINED_RAMDISK_RECOVERY_TARGET)
endif # TARGET_BOOT_MANAGER
endif # AB_OTA_UPDATER

##### persist #####
INSTALLED_PERSISTIMAGE_TARGET_DEPS :=

endif # USES_DEVICE_VIRT_VIRT_COMMON
