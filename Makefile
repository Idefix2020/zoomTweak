TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

FINALPACKAGE=0
DEBUG=1

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = zoomTweak

zoomTweak_FILES = Tweak.xm
zoomTweak_CFLAGS = -fobjc-arc
zoomTweak_FRAMEWORKS = UIKit,Framework

include $(THEOS_MAKE_PATH)/tweak.mk
