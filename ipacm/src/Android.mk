BOARD_PLATFORM_LIST := test
BOARD_PLATFORM_LIST += msmnile
BOARD_IPAv3_LIST := msm8998
BOARD_IPAv3_LIST += sdm845
BOARD_IPAv3_LIST += sdm710
ifeq (,$(call is-board-platform-in-list2,$(BOARD_PLATFORM_LIST)))
ifneq (,$(filter $(QCOM_BOARD_PLATFORMS),$(TARGET_BOARD_PLATFORM)))
ifneq (, $(filter aarch64 arm arm64, $(TARGET_ARCH)))

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../src
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../inc

ifeq ($(TARGET_COMPILE_WITH_MSM_KERNEL),true)
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr
endif

LOCAL_CFLAGS += -DFEATURE_IPA_ANDROID
LOCAL_CFLAGS += -DFEATURE_IPACM_HAL -Wall -Werror -Wno-error=macro-redefined -Wno-enum-compare
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
LOCAL_CFLAGS += -DDEBUG
endif

ifneq (,$(call is-board-platform-in-list2,$(BOARD_IPAv3_LIST)))
LOCAL_CFLAGS += -DFEATURE_IPA_V3
endif

filetoadd = bionic/libc/kernel/arch-arm/asm/posix_types.h
LOCAL_CFLAGS += $(shell if [ -a $(filetoadd) ] ; then echo -include $(filetoadd) ; fi ;)
filetoadd = bionic/libc/kernel/arch-arm/asm/byteorder.h
LOCAL_CFLAGS += $(shell if [ -a $(filetoadd) ] ; then echo -include $(filetoadd) ; fi ;)

# Allow warnings in IPACM_Main.cpp until they are fixed.
LOCAL_CFLAGS += -Wno-error=implicit-fallthrough

LOCAL_SRC_FILES := IPACM_Main.cpp \
		IPACM_EvtDispatcher.cpp \
		IPACM_Config.cpp \
		IPACM_CmdQueue.cpp \
		IPACM_Filtering.cpp \
		IPACM_Routing.cpp \
		IPACM_Header.cpp \
		IPACM_Lan.cpp \
		IPACM_Iface.cpp \
		IPACM_Wlan.cpp \
		IPACM_Wan.cpp \
		IPACM_IfaceManager.cpp \
		IPACM_Neighbor.cpp \
		IPACM_Netlink.cpp \
		IPACM_Xml.cpp \
		IPACM_Conntrack_NATApp.cpp\
		IPACM_ConntrackClient.cpp \
		IPACM_ConntrackListener.cpp \
		IPACM_Log.cpp \
		IPACM_OffloadManager.cpp

LOCAL_MODULE := ipacm
LOCAL_LICENSE_KINDS := SPDX-license-identifier-BSD
LOCAL_LICENSE_CONDITIONS := notice
LOCAL_CLANG := false
LOCAL_MODULE_TAGS := optional

LOCAL_SHARED_LIBRARIES := liboffloadhal
LOCAL_SHARED_LIBRARIES += libipanat
LOCAL_SHARED_LIBRARIES += libxml2
LOCAL_SHARED_LIBRARIES += libnfnetlink
LOCAL_SHARED_LIBRARIES += libnetfilter_conntrack
LOCAL_SHARED_LIBRARIES += \
                libhidlbase \
                liblog \
                libcutils \
                libdl \
                libbase \
                libutils \
                libhardware_legacy \
                libhardware \
                android.hardware.tetheroffload.config@1.0 \
                android.hardware.tetheroffload.control@1.0

LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_EXECUTABLES)

LOCAL_CLANG := true
include $(BUILD_EXECUTABLE)

################################################################################

define ADD_TEST

include $(CLEAR_VARS)
LOCAL_MODULE       := $1
LOCAL_LICENSE_KINDS := SPDX-license-identifier-BSD
LOCAL_LICENSE_CONDITIONS := notice
LOCAL_SRC_FILES    := $1
LOCAL_MODULE_CLASS := ipacm
LOCAL_MODULE_TAGS  := debug
LOCAL_MODULE_PATH  := $(TARGET_OUT_ETC)
include $(BUILD_PREBUILT)

endef

include $(CLEAR_VARS)
LOCAL_MODULE := IPACM_cfg.xml
LOCAL_LICENSE_KINDS := SPDX-license-identifier-BSD
LOCAL_LICENSE_CONDITIONS := notice
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR_ETC)
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(LOCAL_MODULE)
LOCAL_MODULE_OWNER := ipacm
include $(BUILD_PREBUILT)

endif # $(TARGET_ARCH)
endif
endif
