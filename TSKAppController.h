//
//  TSKAppController.h
//  Taskation
//
//  Created by Lyndsey on 9/27/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKAboutWindowController;
@class TSKPrefsWindowController;
@class TSKDefinitions;

@interface TSKAppController : NSObject {
	TSKPrefsWindowController* prefsWindowController;
	TSKAboutWindowController* aboutWindowController;
	
	NSString* registeredUserName;
}

@property (readonly) NSString* registeredUserName;

+ (void)initialize;

#pragma mark -
#pragma mark Application Menu Items
- (IBAction)aboutMenuItemSelected:(id)sender;
- (IBAction)prefsMenuItemSelected:(id)sender;
- (void)registerMenuItemSelected:(id)sender;
- (BOOL)isRegisterMenuItemSelected;

- (void)updateDefaultPreferences:(NSDictionary*)preferenceDict;
- (void)registerMenuItemSelected:(id)sender;

#pragma mark -
#pragma mark File Menu Items
- (IBAction)openMenuItemSelected:(id)sender;
- (IBAction)newMenuItemSelected:(id)sender;
- (void)appendRecentFileURL:(NSURL*)recentFileURL;

#pragma mark -
#pragma mark Delgationary
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void)displayLicenseStatus:(id)unused;

- (id)currentPulseStatus:(NSString*)licenseOwner;

@end

typedef enum {
#ifdef TSK_CONFIGURATION_DEBUG
	ePulseState_ValidatingStoredLicense,
#else
	ePulseState_Initialization,
#endif
	ePulseState_Starting,
#ifdef TSK_CONFIGURATION_DEBUG
	ePulseState_ValidatingLicenseEntry,
#else
	ePulseState_Paused,
#endif
	ePulseState_Stopped
} EPulseState;

#ifdef TSK_CONFIGURATION_DEBUG
#define FAKE_PULSE_STATE_VALIDATE_STORED_LICENSE ePulseState_ValidatingStoredLicense
#define FAKE_PULSE_STATE_VALIDATE_LICENSE_ENTRY ePulseState_ValidatingLicenseEntry
#else
#define FAKE_PULSE_STATE_VALIDATE_STORED_LICENSE ePulseState_Initialization
#define FAKE_PULSE_STATE_VALIDATE_LICENSE_ENTRY ePulseState_Paused
#endif

#define TSK_LICENSE_KEY_USERNAME @"license owner"
#define TSK_LICENSE_KEY_NUMBER @"license key"