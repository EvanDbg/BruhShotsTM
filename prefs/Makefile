export TARGET = iphone:clang::11.0
include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e

BUNDLE_NAME = bruhshotsprefs

bruhshotsprefs_FILES = BSTMRootListController.m TR1LinkCell.m TR1TableCell.m TR1TwitterCell.m
bruhshotsprefs_INSTALL_PATH = /Library/PreferenceBundles
bruhshotsprefs_FRAMEWORKS = UIKit
bruhshotsprefs_PRIVATE_FRAMEWORKS = Preferences
bruhshotsprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/prefs.plist$(ECHO_END)
