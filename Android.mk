#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(USES_DEVICE_VIRT_VIRT_COMMON),true)

# Combine ramdisk
ifneq ($(AB_OTA_UPDATER),true)

INSTALLED_COMBINED_RAMDISK_TARGET := $(PRODUCT_OUT)/combined-ramdisk.img
INSTALLED_COMBINED_RAMDISK_TARGET_DEPS := $(PRODUCT_OUT)/ramdisk.img $(PRODUCT_OUT)/vendor_ramdisk.img

$(INSTALLED_COMBINED_RAMDISK_TARGET): $(INSTALLED_COMBINED_RAMDISK_TARGET_DEPS)
	cat $^ > $@

.PHONY: combined-ramdisk
combined-ramdisk: $(INSTALLED_COMBINED_RAMDISK_TARGET)

endif # AB_OTA_UPDATER

INSTALLED_COMBINED_RAMDISK_RECOVERY_TARGET := $(PRODUCT_OUT)/combined-ramdisk-recovery.img
INSTALLED_COMBINED_RAMDISK_RECOVERY_TARGET_DEPS := $(PRODUCT_OUT)/ramdisk-recovery.img $(PRODUCT_OUT)/vendor_ramdisk.img

$(INSTALLED_COMBINED_RAMDISK_RECOVERY_TARGET): $(INSTALLED_COMBINED_RAMDISK_RECOVERY_TARGET_DEPS)
	cat $^ > $@

.PHONY: combined-ramdisk-recovery
combined-ramdisk-recovery: $(INSTALLED_COMBINED_RAMDISK_RECOVERY_TARGET)

# Create vda disk image
SGDISK_EXEC := out/host/linux-x86/bin/sgdisk

DISK_VDA_SECTOR_SIZE := 512
ifeq ($(AB_OTA_UPDATER),true)
	DISK_VDA_SECTORS := 27262976
	DISK_VDA_PARTITION_EFI_START_SECTOR := 2048
	DISK_VDA_PARTITION_EFI_A_START_SECTOR := $(DISK_VDA_PARTITION_EFI_START_SECTOR)
	DISK_VDA_PARTITION_EFI_B_START_SECTOR := $(DISK_VDA_PARTITION_EFI_START_SECTOR)
	DISK_VDA_PARTITION_SUPER_START_SECTOR := 264192
	DISK_VDA_PARTITION_MISC_START_SECTOR := 25430016
	DISK_VDA_PARTITION_PERSIST_START_SECTOR := 25432064
	DISK_VDA_PARTITION_METADATA_START_SECTOR := 25464832
	DISK_VDA_PARTITION_FIRMWARE_START_SECTOR := 25530368
	DISK_VDA_PARTITION_GRUB_BOOT_A_START_SECTOR := 25792512
	DISK_VDA_PARTITION_GRUB_BOOT_B_START_SECTOR := 25997312
	DISK_VDA_PARTITION_BOOT_A_START_SECTOR := 26202112
	DISK_VDA_PARTITION_BOOT_B_START_SECTOR := 26365952
	DISK_VDA_PARTITION_EFI_SECTORS := 262144
	DISK_VDA_PARTITION_EFI_A_SECTORS := $(DISK_VDA_PARTITION_EFI_SECTORS)
	DISK_VDA_PARTITION_EFI_B_SECTORS := $(DISK_VDA_PARTITION_EFI_SECTORS)
	DISK_VDA_PARTITION_SUPER_SECTORS := 25165824
	DISK_VDA_PARTITION_MISC_SECTORS := 2048
	DISK_VDA_PARTITION_PERSIST_SECTORS := 32768
	DISK_VDA_PARTITION_METADATA_SECTORS := 65536
	DISK_VDA_PARTITION_FIRMWARE_SECTORS := 262144
	DISK_VDA_PARTITION_GRUB_BOOT_A_SECTORS := 204800
	DISK_VDA_PARTITION_GRUB_BOOT_B_SECTORS := 204800
	DISK_VDA_PARTITION_BOOT_A_SECTORS := 163840
	DISK_VDA_PARTITION_BOOT_B_SECTORS := 163840

	DISK_VDA_WRITE_PARTITIONS := \
		EFI \
		super \
		grub_boot \
		boot
else
	ifeq ($(BOARD_SUPER_PARTITION_SIZE),3221225472)
		DISK_VDA_SECTORS := 8388608
		DISK_VDA_PARTITION_EFI_START_SECTOR := 2048
		DISK_VDA_PARTITION_SUPER_START_SECTOR := 526336
		DISK_VDA_PARTITION_MISC_START_SECTOR := 6817792
		DISK_VDA_PARTITION_METADATA_START_SECTOR := 6819840
		DISK_VDA_PARTITION_CACHE_START_SECTOR := 6885376
		DISK_VDA_PARTITION_BOOT_START_SECTOR := 6987776
		DISK_VDA_PARTITION_RECOVERY_START_SECTOR := 7118848
		DISK_VDA_PARTITION_FIRMWARE_START_SECTOR := 7249920
		DISK_VDA_PARTITION_PERSIST_START_SECTOR := 7512064
		DISK_VDA_PARTITION_EFI_SECTORS := 524288
		DISK_VDA_PARTITION_SUPER_SECTORS := 6291456
		DISK_VDA_PARTITION_MISC_SECTORS := 2048
		DISK_VDA_PARTITION_METADATA_SECTORS := 65536
		DISK_VDA_PARTITION_CACHE_SECTORS := 102400
		DISK_VDA_PARTITION_BOOT_SECTORS := 131072
		DISK_VDA_PARTITION_RECOVERY_SECTORS := 131072
		DISK_VDA_PARTITION_FIRMWARE_SECTORS := 262144
		DISK_VDA_PARTITION_PERSIST_SECTORS := 32768
	else ifeq ($(BOARD_SUPER_PARTITION_SIZE),4294967296)
		DISK_VDA_SECTORS := 10485760
		DISK_VDA_PARTITION_EFI_START_SECTOR := 2048
		DISK_VDA_PARTITION_SUPER_START_SECTOR := 526336
		DISK_VDA_PARTITION_MISC_START_SECTOR := 8925184
		DISK_VDA_PARTITION_METADATA_START_SECTOR := 8927232
		DISK_VDA_PARTITION_CACHE_START_SECTOR := 8992768
		DISK_VDA_PARTITION_BOOT_START_SECTOR := 9096960
		DISK_VDA_PARTITION_RECOVERY_START_SECTOR := 9228032
		DISK_VDA_PARTITION_FIRMWARE_START_SECTOR := 9359104
		DISK_VDA_PARTITION_PERSIST_START_SECTOR := 9621248
		DISK_VDA_PARTITION_EFI_SECTORS := 524288
		DISK_VDA_PARTITION_SUPER_SECTORS := 8388608
		DISK_VDA_PARTITION_MISC_SECTORS := 2048
		DISK_VDA_PARTITION_METADATA_SECTORS := 65536
		DISK_VDA_PARTITION_CACHE_SECTORS := 102400
		DISK_VDA_PARTITION_BOOT_SECTORS := 131072
		DISK_VDA_PARTITION_RECOVERY_SECTORS := 131072
		DISK_VDA_PARTITION_FIRMWARE_SECTORS := 262144
		DISK_VDA_PARTITION_PERSIST_SECTORS := 32768
	else
		$(error Unsupported BOARD_SUPER_PARTITION_SIZE for vda disk image creation)
	endif

	DISK_VDA_WRITE_PARTITIONS := \
		EFI \
		super \
		cache \
		boot \
		recovery
endif

# $(1): output file
# $(2): disk name
define make-diskimage-target
	$(call pretty,"Target $(2) disk image: $(1)")
	/bin/dd if=/dev/zero of=$(1) bs=$(DISK_$(call to-upper,$(2))_SECTOR_SIZE) count=$(DISK_$(call to-upper,$(2))_SECTORS)
	/bin/sh -e $(VIRT_COMMON_PATH)/configs/scripts/create_partition_table.sh $(SGDISK_EXEC) $(1) $(2) $(AB_OTA_UPDATER) $(BOARD_SUPER_PARTITION_SIZE)
	$(foreach p,$(DISK_$(call to-upper,$(2))_WRITE_PARTITIONS),\
		$(if $(filter $(p),$(AB_OTA_PARTITIONS)),\
			$(foreach ab_slot_suffix,_A _B,\
				/bin/dd if=$(PRODUCT_OUT)/$(p).img of=$(1) bs=$(DISK_$(call to-upper,$(2))_SECTOR_SIZE) seek=$(DISK_$(call to-upper,$(2))_PARTITION_$(call to-upper,$(p))$(ab_slot_suffix)_START_SECTOR) count=$(DISK_$(call to-upper,$(2))_PARTITION_$(call to-upper,$(p))$(ab_slot_suffix)_SECTORS) conv=notrunc &&\
			)\
		,\
			/bin/dd if=$(PRODUCT_OUT)/$(p).img of=$(1) bs=$(DISK_$(call to-upper,$(2))_SECTOR_SIZE) seek=$(DISK_$(call to-upper,$(2))_PARTITION_$(call to-upper,$(p))_START_SECTOR) count=$(DISK_$(call to-upper,$(2))_PARTITION_$(call to-upper,$(p))_SECTORS) conv=notrunc &&\
		)\
	)true
endef

INSTALLED_DISKIMAGE_VDA_TARGET := $(PRODUCT_OUT)/disk-vda.img
INSTALLED_DISKIMAGE_VDA_TARGET_DEPS := $(SGDISK_EXEC)
$(foreach p,$(DISK_VDA_WRITE_PARTITIONS),\
	$(eval INSTALLED_DISKIMAGE_VDA_TARGET_DEPS += $(PRODUCT_OUT)/$(p).img))
$(INSTALLED_DISKIMAGE_VDA_TARGET): $(INSTALLED_DISKIMAGE_VDA_TARGET_DEPS)
	$(call make-diskimage-target,$(INSTALLED_DISKIMAGE_VDA_TARGET),vda)

.PHONY: diskimage-vda
diskimage-vda: $(INSTALLED_DISKIMAGE_VDA_TARGET)

.PHONY: diskimage-vda-nodeps
diskimage-vda-nodeps:
	@echo "make $(INSTALLED_DISKIMAGE_VDA_TARGET): ignoring dependencies"
	$(call make-diskimage-target,$(INSTALLED_DISKIMAGE_VDA_TARGET),vda)

# Firmware mount point
FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/firmware_mnt
ALL_DEFAULT_INSTALLED_MODULES += $(FIRMWARE_MOUNT_POINT)

$(FIRMWARE_MOUNT_POINT):
	@echo "Creating $(FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/firmware_mnt

# Radio files
ifneq ($(TARGET_BOOT_MANAGER),)
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/EFI.img
$(PRODUCT_OUT)/EFI.img : $(PRODUCT_OUT)/obj/CUSTOM_IMAGES/EFI.img
	$(transform-prebuilt-to-target)
endif # TARGET_BOOT_MANAGER

ifeq ($(AB_OTA_UPDATER),true)
ifeq ($(TARGET_BOOT_MANAGER),grub)
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/grub_boot.img
$(PRODUCT_OUT)/grub_boot.img : $(PRODUCT_OUT)/obj/CUSTOM_IMAGES/grub_boot.img
	$(transform-prebuilt-to-target)
endif # TARGET_BOOT_MANAGER
endif # AB_OTA_UPDATER

# Super image (empty)
LPFLASH := $(HOST_OUT_EXECUTABLES)/lpflash$(HOST_EXECUTABLE_SUFFIX)
INSTALLED_RECOVERY_SUPERIMAGE_EMPTY_RAW_TARGET := $(PRODUCT_OUT)/recovery/root/system/etc/super_empty_raw.img
$(INSTALLED_RECOVERY_SUPERIMAGE_EMPTY_RAW_TARGET): $(LPFLASH) $(PRODUCT_OUT)/super_empty.img
	touch $@
	$(LPFLASH) $$(realpath $@) $(PRODUCT_OUT)/super_empty.img

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_RECOVERY_SUPERIMAGE_EMPTY_RAW_TARGET)

# Include other makefiles
include $(call all-makefiles-under,$(LOCAL_PATH))

# Wi-Fi
include external/wpa_supplicant_8/wpa_supplicant/wpa_supplicant_conf.mk

endif
