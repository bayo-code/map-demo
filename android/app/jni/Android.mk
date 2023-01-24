LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := organicmaps
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/liborganicmaps.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES  := dummy.c
LOCAL_MODULE     :=  use-lib
LOCAL_SHARED_LIBRARIES := organicmaps
include $(BUILD_SHARED_LIBRARY)