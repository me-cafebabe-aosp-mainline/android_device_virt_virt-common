#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Audio
PRODUCT_PACKAGES += \
    com.android.hardware.audio

PRODUCT_COPY_FILES += \
    device/generic/goldfish/audio/policy/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    device/generic/goldfish/audio/policy/primary_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/primary_audio_policy_configuration.xml \
    hardware/interfaces/audio/aidl/default/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects_config.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration_7_0.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.1-service.btlinux

ifneq ($(PRODUCT_IS_ATV),true)
ifneq ($(PRODUCT_IS_AUTOMOTIVE),true)
# Set the Bluetooth Class of Device
# Service Field: 0x1A -> 26
#    Bit 17: Networking
#    Bit 19: Capturing
#    Bit 20: Object Transfer
# MAJOR_CLASS: 0x01 -> 1 (Computer)
# MINOR_CLASS: 0x04 -> 4 (Desktop workstation)
PRODUCT_VENDOR_PROPERTIES += \
    bluetooth.device.class_of_device=26,1,4
endif
endif

# Dynamic partitions
PRODUCT_BUILD_SUPER_PARTITION := true
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Dalvik heap
$(call inherit-product, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)

# DHCP client
PRODUCT_PACKAGES += \
    virt_dhcpclient.recovery

# DLKM Loader
PRODUCT_PACKAGES += \
    dlkm_loader

# EFI
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/bootmgr/rEFInd/refind-update-default_selection.sh:$(TARGET_COPY_OUT_VENDOR)/bin/refind-update-default_selection.sh

# Fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot-service.virt_recovery \
    fastbootd

# Gatekeeper
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-service.software

# Graphics (Swiftshader)
PRODUCT_PACKAGES += \
    com.google.cf.vulkan

TARGET_VULKAN_SUPPORT := true

$(call inherit-product, device/google/cuttlefish/shared/swiftshader/device_vendor.mk)

# Health
ifneq ($(LINEAGE_BUILD),)
PRODUCT_PACKAGES += \
    android.hardware.health-service.batteryless \
    android.hardware.health-service.batteryless_recovery
else
PRODUCT_PACKAGES += \
    android.hardware.health-service.cuttlefish_recovery \
    com.google.cf.health
endif

# Init
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/config/init.virt.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.virt.rc \
    $(LOCAL_PATH)/config/ueventd.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Input
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/config/Generic.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/Generic.kl \
    $(LOCAL_PATH)/tablet2multitouch/uinput_multitouch_device.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/uinput_multitouch_device.idc

# Images
PRODUCT_BUILD_BOOT_IMAGE := true
PRODUCT_BUILD_RAMDISK_IMAGE := true
PRODUCT_BUILD_RECOVERY_IMAGE := true
PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true

# Kernel
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

# Keymint
PRODUCT_PACKAGES += \
    android.hardware.security.keymint-service

# Low performance optimizations
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/low_performance/init.low_performance.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.low_performance.rc

PRODUCT_PACKAGES += \
    LowPerformanceSettingsProviderOverlay

# Memtrack
PRODUCT_PACKAGES += \
    com.android.hardware.memtrack

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay

ifneq ($(LINEAGE_BUILD),)
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay-lineage
endif

PRODUCT_ENFORCE_RRO_TARGETS := *

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.software.credentials.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.credentials.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

ifeq ($(PRODUCT_IS_AUTOMOTIVE),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/car_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/car_core_hardware.xml
else ifneq ($(PRODUCT_IS_ATV),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/pc_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/pc_core_hardware.xml
endif

# Recovery
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/bootmgr/rEFInd/refind-update-default_selection.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/refind-update-default_selection.sh \
    $(LOCAL_PATH)/config/create_partition_table.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/create_partition_table.sh \
    $(LOCAL_PATH)/config/init.recovery.virt.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.virt.rc \
    $(LOCAL_PATH)/config/ueventd.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/ueventd.rc \
    device/google/cuttlefish/shared/config/cgroups.json:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/cgroups.json

# Shipping API level
# (Stays on 30 due to target-level)
PRODUCT_SHIPPING_API_LEVEL := 30

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Suspend blocker
PRODUCT_PACKAGES += \
    suspend_blocker

# Tablet to multitouch
PRODUCT_PACKAGES += \
    tablet2multitouch

# UFFD GC
OVERRIDE_ENABLE_UFFD_GC := false

# Utilities
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/config/pci.ids:$(TARGET_COPY_OUT_VENDOR)/pci.ids

PRODUCT_PACKAGES += \
    sgdisk.recovery

# VirtWifi
PRODUCT_PACKAGES += \
    setup_wifi

# Wakeupd
PRODUCT_PACKAGES += \
    wakeupd

# Wi-Fi
PRODUCT_COPY_FILES += \
    device/google/cuttlefish/shared/config/p2p_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant.conf \
    device/google/cuttlefish/shared/config/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

PRODUCT_PACKAGES += \
    hostapd \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_PACKAGES += \
    CuttlefishTetheringOverlay \
    CuttlefishWifiOverlay
