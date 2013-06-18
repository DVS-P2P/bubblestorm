LOCAL_PATH:= $(call my-dir)

# BubbleStorm (incl. CUSP)

include $(CLEAR_VARS)

LOCAL_MODULE    := bsjni
LOCAL_CFLAGS    := -Wall -DLIBRARY_NAME=bubblestorm -DDISABLE_SIGNALS -I../../c/android-arm -I../../common -I../../cusp -I../../bubblestorm
LOCAL_SRC_FILES := ../../bubblestorm/bs-jni.c
LOCAL_LDLIBS    := -L../../c/android-arm -lbubblestorm -llog

include $(BUILD_SHARED_LIBRARY)


# CUSP only

include $(CLEAR_VARS)

LOCAL_MODULE    := cuspjni
LOCAL_CFLAGS    := -Wall -DLIBRARY_NAME=cusp -DDISABLE_SIGNALS -I../../c/android-arm -I../../common -I../../cusp
LOCAL_SRC_FILES := ../../cusp/cusp-jni.c
LOCAL_LDLIBS    := -L../../c/android-arm -lcusp -llog

include $(BUILD_SHARED_LIBRARY)
