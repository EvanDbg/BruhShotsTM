export TARGET = iphone:clang:11.2:11.0
FINALPACKAGE=1
include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e

TWEAK_NAME = BruhShotsTM

BruhShotsTM_FILES = Tweak.xm UIImage+drawText.m server.m
BruhShotsTM_CFLAGS = -fobjc-arc
BruhShotsTM_LIBRARIES = rocketbootstrap
BruhShotsTM_PRIVATE_FRAMEWORKS = Preferences AppSupport
BruhShotsTM_EXTRA_FRAMEWORKS = Cephei
SUBPROJECTS += prefs

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "sbreload"

include $(THEOS_MAKE_PATH)/aggregate.mk
