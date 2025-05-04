PRODUCT_VERSION_MAJOR = 1
PRODUCT_VERSION_MINOR = 3
PRODUCT_RELEASE_TYPE = NIGHTLY

CURRENT_DEVICE := $(wordlist 2,3,$(subst _, ,$(TARGET_PRODUCT)))
DEVICE_LIST := $(file < vendor/official_devices/OTA/axion.devices)
MAINTAINER_LIST := $(file < vendor/official_devices/OTA/axion.maintainers)

LINEAGE_BUILDTYPE ?= COMMUNITY

ifneq ($(filter $(CURRENT_DEVICE),$(DEVICE_LIST)),)
    ifneq ($(AXION_MAINTAINER),)
        ifneq ($(filter $(AXION_MAINTAINER),$(MAINTAINER_LIST)),)
            LINEAGE_BUILDTYPE := OFFICIAL
        endif
    endif
endif

ifeq ($(LINEAGE_VERSION_APPEND_TIME_OF_DAY),true)
    LINEAGE_BUILD_DATE := $(shell date -u +%Y%m%d%H%M%S)
else
    LINEAGE_BUILD_DATE := $(shell date -u +%Y%m%d)
endif

ifeq ($(WITH_GMS),true)
AXION_BUILD_VARIANT := GMS
else
AXION_BUILD_VARIANT := VANILLA
endif

LINEAGE_VERSION_SUFFIX := $(LINEAGE_BUILD_DATE)-$(LINEAGE_BUILDTYPE)-$(AXION_BUILD_VARIANT)-$(LINEAGE_BUILD)

# Internal version
LINEAGE_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(PRODUCT_RELEASE_TYPE)-$(LINEAGE_VERSION_SUFFIX)

# Display version
LINEAGE_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR)-$(LINEAGE_VERSION_SUFFIX)

# LineageOS version properties
PRODUCT_SYSTEM_PROPERTIES += \
    ro.lineage.version=$(LINEAGE_VERSION) \
    ro.lineage.display.version=$(LINEAGE_DISPLAY_VERSION) \
    ro.lineage.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.lineage.releasetype=$(LINEAGE_BUILDTYPE)

AXION_CPU_SMALL_CORES ?= 0,1,2,3
AXION_CPU_BIG_CORES ?= 4,5,6,7
AXION_CPU_BG ?= 0-2
AXION_CPU_FG ?= 0-5
AXION_CPU_LIMIT_BG ?= 0-1
BYPASS_CHARGE_SUPPORTED ?= false
AXION_DEBUGGING_ENABLED ?= false
# 2 small cores only
DEX2OAT_CORES ?= 0,1
# AxionOS properties
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.device_camera_info_rear=$(AXION_CAMERA_REAR_INFO) \
    persist.sys.device_camera_info_front=$(AXION_CAMERA_FRONT_INFO) \
    persist.sys.axion_maintainer=$(AXION_MAINTAINER) \
    persist.sys.axion_processor_info=$(AXION_PROCESSOR)\
    persist.sys.axion_cpu_big=$(AXION_CPU_BIG_CORES) \
    persist.sys.axion_cpu_small=$(AXION_CPU_SMALL_CORES) \
    persist.sys.battery_bypass_supported=$(BYPASS_CHARGE_SUPPORTED) \
    persist.sys.axion_cpu_bg=$(AXION_CPU_BG) \
    persist.sys.axion_cpu_limit_bg=$(AXION_CPU_LIMIT_BG) \
    persist.sys.axion_cpu_fg=$(AXION_CPU_FG) \
    ro.sys.axion_userdebug_enabled=$(AXION_DEBUGGING_ENABLED)

# dex2oat
PRODUCT_SYSTEM_PROPERTIES += \
    dalvik.vm.dex2oat-threads=2 \
    dalvik.vm.restore-dex2oat-threads=2 \
    dalvik.vm.dex2oat-cpu-set=$(DEX2OAT_CORES) \
    dalvik.vm.restore-dex2oat-cpu-set=$(DEX2OAT_CORES)
