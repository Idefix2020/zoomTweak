TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = Zoom

FINALPACKAGE=1
DEBUG=0

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = zoomTweak

zoomTweak_FILES = Tweak.xm
zoomTweak_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
