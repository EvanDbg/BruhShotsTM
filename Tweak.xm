#include "Preferences/PSSpecifier.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import "CPDistributedMessagingCenter.h"
#import <Foundation/NSUserDefaults.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#import "UIImage+drawText.h"
#import "server.h"
#import "Tweak.h"


#define PLIST_DOMAIN "com.tr1fecta.bruhshotstm.prefs"
#define kPhotoShutterSystemSound 0x454
BOOL tweakEnabled;
BOOL screenshotSoundEnabled;
BOOL watermarkingEnabled;
double watermarkingAlpha;
double watermarkingFontSize;
NSString *watermarkingRotation;
NSString *watermarkingText;

static NSMutableDictionary* prefsDictionary() {
	NSMutableDictionary *settings;

	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR(PLIST_DOMAIN), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR(PLIST_DOMAIN), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		settings = nil;
	}

	if (!settings) {
		settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tr1fecta.bruhshotstm.prefs.plist"];
	}

	return settings;
}

static BOOL GetPrefBool(NSDictionary *settings, NSString* key, BOOL fallback) {
	if (!settings) {
		settings = (NSMutableDictionary *)prefsDictionary();
    	NSNumber* value = [settings objectForKey:key];
    	return value ? [value boolValue] : fallback;
	}

	NSNumber* value = [settings objectForKey:key];
	return value ? [value boolValue] : fallback;
}

static id GetObjectForKey(NSDictionary *settings, NSString* key, id fallback) {
	if (!settings) {
		settings = (NSMutableDictionary *)prefsDictionary();
		id value = [settings objectForKey:key];
		return value ? value : fallback;
	}

	id value = [settings objectForKey:key];
	return value ? value : fallback;
}

static double GetPrefDouble(NSDictionary *settings, NSString* key, double fallback) {
	if (!settings) {
		settings = (NSMutableDictionary *)prefsDictionary();
		id value = [settings objectForKey:key];
		return value ? [value doubleValue] : fallback;
	}

	id value = [settings objectForKey:key];
	return value ? [value doubleValue] : fallback;
}

void soundCompleteCallback(SystemSoundID soundID, void * clientData) {
	AudioServicesRemoveSystemSoundCompletion(soundID);
	AudioServicesDisposeSystemSoundID(soundID);
}


%hookf(void, AudioServicesPlaySystemSound, SystemSoundID inSystemSoundID) {
	if (inSystemSoundID == kPhotoShutterSystemSound) {
		if (GetPrefBool(nil, @"kScreenshotSoundEnabled", NO)) {
			// create a NSURL with the file path of the wav bruh sound file
			NSURL *bruhFileURL = [NSURL fileURLWithPath:@"/Library/Application Support/BruhShotsTM/bruhSound.wav"];
			// Store the URL as a CFURLRef instance
			CFURLRef soundFileURLRef = (__bridge CFURLRef)bruhFileURL;
			SystemSoundID soundFileObject;

			// Create a system sound object representing the sound file.
			AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
			AudioServicesAddSystemSoundCompletion(soundFileObject, NULL, NULL, soundCompleteCallback, NULL);
			%orig(soundFileObject);
			return;
		}
		%orig;
		return;
	}
	%orig;
}

%hook SSScreenCapturer

-(void)_saveImageToPhotoLibrary:(UIImage *)image environmentDescription:(id)env {
	if (tweakEnabled && watermarkingEnabled) {
		WatermarkRotation rotation = [self currentRotation];
		UIImage *watermarkBruhImage = [UIImage drawText:watermarkingText diagonallyOnImage:image alpha:watermarkingAlpha fontSize:watermarkingFontSize rotation:rotation];
		%orig(watermarkBruhImage, env);
	}
	else {
		%orig(image, env);
	}
	
}

%new
-(WatermarkRotation)currentRotation {
	WatermarkRotation rotation;

	if ([watermarkingRotation isEqualToString:@"kWatermarkRotate45LeftToRight"]) {
		rotation = WatermarkRotation45ltr;
	}
	else if ([watermarkingRotation isEqualToString:@"kWatermarkRotate45RightToLeft"]) {
		rotation = WatermarkRotation45rtl;
	}
	else if ([watermarkingRotation isEqualToString:@"kWatermarkRotate90Left"]) {
		rotation = WatermarkRotation90left;
	}
	else if ([watermarkingRotation isEqualToString:@"kWatermarkRotate90Right"]) {
		rotation = WatermarkRotation90right;
	}
	else {
		rotation = WatermarkRotation45ltr;
	}
	return rotation;
}


%end



static void loadPrefs() {
	tweakEnabled = GetPrefBool(nil, @"kTweakEnabled", NO);
    screenshotSoundEnabled = GetPrefBool(nil, @"kScreenshotSoundEnabled", NO);
	watermarkingEnabled = GetPrefBool(nil, @"kWatermarkingEnabled", NO);
    watermarkingText = GetObjectForKey(nil, @"kWatermarkingText", @"Epic watermarkTM");
	watermarkingAlpha = GetPrefDouble(nil, @"kWatermarkingAlpha", 0.4);
	watermarkingFontSize = GetPrefDouble(nil, @"kWatermarkingFontSize", 65);
	watermarkingRotation = GetObjectForKey(nil, @"kWatermarkingRotation", @"kWatermarkRotate45Right");
}


static void myOtherLoadPrefsThingAccordingToScoob() {
	CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.tr1fecta.bruhshotstm.prefs"];
  	NSDictionary *preferences = [center sendMessageAndReceiveReplyName:@"get" userInfo:nil];

	tweakEnabled = GetPrefBool(preferences, @"kTweakEnabled", NO);
    screenshotSoundEnabled = GetPrefBool(preferences, @"kScreenshotSoundEnabled", NO);
	watermarkingEnabled = GetPrefBool(preferences, @"kWatermarkingEnabled", NO);
    watermarkingText = GetObjectForKey(preferences, @"kWatermarkingText", @"Epic watermarkTM");
	watermarkingAlpha = GetPrefDouble(preferences, @"kWatermarkingAlpha", 0.4);
	watermarkingFontSize = GetPrefDouble(preferences, @"kWatermarkingFontSize", 65);
	watermarkingRotation = GetObjectForKey(preferences, @"kWatermarkingRotation", @"kWatermarkRotate45Right");

}

%ctor {
	if ([NSBundle.mainBundle.bundleIdentifier isEqual:@"com.apple.springboard"]) {
		[BruhShotsTMServer load];
		loadPrefs();
		CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.tr1fecta.bruhshotstm.prefs"];
		[center sendMessageName:@"set" userInfo:prefsDictionary()];
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.tr1fecta.bruhshotstm.prefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
	else {
		myOtherLoadPrefsThingAccordingToScoob();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)myOtherLoadPrefsThingAccordingToScoob, CFSTR("com.tr1fecta.bruhshotstm.prefs/set"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
	
}