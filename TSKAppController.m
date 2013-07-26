//
//  TSKAppController.m
//  Taskation
//
//  Created by Lyndsey on 9/27/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import "TSKAppController.h"
#import "TSKDocWindowController.h"
#import "TSKDefinitions.h"
#import "TSKPrefsWindowController.h"
#import "TSKAboutWindowController.h"
#import "TSKLicenseDialogController.h"
#import "SSCrypto.h"
#import "TSKRegisterDialogController.h"
#import "TSKEULAWindowController.h"

/**
  License Validation Bytes.
*/

extern unsigned char markChar; // Uses INVALID_LICENSE_BYTE1 and VALID_LICENSE_BYTE1
extern unsigned char modder; // Uses INVALID_LICENSE_BYTE2 and VALID_LICENSE_BYTE2


@implementation TSKAppController

@synthesize registeredUserName;

+ (void)registerDefaultPreferences
{
	NSMutableDictionary* defaultValues = [NSMutableDictionary dictionary];

	NSBundle* mainBundle = [NSBundle mainBundle];
	
	NSDictionary* defaultActions = [NSDictionary dictionaryWithContentsOfFile:[mainBundle pathForResource:@"DefaultActions" ofType:@"plist"]];
	NSDictionary* defaultSubjects = [NSDictionary dictionaryWithContentsOfFile:[mainBundle pathForResource:@"DefaultSubjects" ofType:@"plist"]];
	NSDictionary* defaultLicense = [NSDictionary dictionary];
	
	
	[defaultValues setObject:defaultActions forKey:TSK_KEY_ACTIONS];
	[defaultValues setObject:defaultSubjects forKey:TSK_KEY_SUBJECTS];
	[defaultValues setObject:defaultLicense forKey:TSK_KEY_LICENSE];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

// ----------------------------------------------------------------------------

- (void)updateDefaultPreferences:(NSDictionary*)preferenceDict
{	
	if (nil != preferenceDict) {
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:preferenceDict forKey:TSK_KEY_LICENSE];
	}
}

// ----------------------------------------------------------------------------

- (id)currentPulseStatus:(NSString*)licenseOwnerName
{
	/* 'THE BLUE TICK TOTES SPEAK EVERYWHERE' */
	const char* salt1Bits[] = {
		"TH", /* 0 */
		"EATR", /* 1 invalid */
		"E ", /* 2 */
		"BL", /* 3 */
		"AME NOV", /* 4 invalid */
		"UE ", /* 5 */
		"S", /* 6 invalid */
		"TICK ", /* 7 */
		"TOTES ", /* 8 */
		"SPEAK ", /* 9 */
		"EVERYWHERE" /* 10 */
	};
		 
	NSString* md5Salt = [NSString stringWithFormat:@"%s%s%s%s%s%s%s%s",	salt1Bits[0],
																		salt1Bits[2],
																		salt1Bits[3],
																		salt1Bits[5],
																		salt1Bits[7],
																		salt1Bits[8],
																		salt1Bits[9],
																		salt1Bits[10]];
		
	NSString* md5DataString = [NSString stringWithFormat:@"%s%s", [licenseOwnerName cStringUsingEncoding:NSASCIIStringEncoding], [md5Salt  cStringUsingEncoding:NSASCIIStringEncoding]];
	
	NSData* md5 = [SSCrypto getMD5ForData:[md5DataString dataUsingEncoding:NSASCIIStringEncoding]];
	
	/* 'ARTHUR IS THE WISE ONE' */
	const char* salt2Bits [] = {
		"ART", /* 0 */
		"ISTIC T", /* 1 invalid */
		"HUR ", /* 2 */
		"IS ", /* 3 */
		"NOT ", /* 4 invalid */
		"THE ", /* 5 */
		"WI", /* 6 */
		"NNER OF", /* 7 invalid */
		"SE", /* 8 */
		"VENTY", /* 9 invalid */
		" ONE" /* 10 */
	};
	
	NSString* shaSalt = [NSString stringWithFormat:@"%s%s%s%s%s%s%s", salt2Bits[0],
																	  salt2Bits[2],
																	  salt2Bits[3],
																	  salt2Bits[5],
																	  salt2Bits[6],
																	  salt2Bits[8],
																	  salt2Bits[10]];

	NSString* shaDataString = [NSString stringWithFormat:@"%s%s", [shaSalt cStringUsingEncoding:NSASCIIStringEncoding], [[md5 hexval] cStringUsingEncoding:NSASCIIStringEncoding]];
	
	NSData* sha = [SSCrypto getSHA1ForData:[shaDataString dataUsingEncoding:NSASCIIStringEncoding]];
	
	const char* shaHexValue = [[sha hexval] cStringUsingEncoding:NSASCIIStringEncoding];
		
	char buffer[25] = {};
	int bufferIndex = 0;
	for (int index = 0; index < 20; index++) {
		if (index > 0 && index % 4 == 0) {
			buffer[bufferIndex++] = '-'; 
		}
		buffer[bufferIndex++] = shaHexValue[index];
	}
	return [[NSString stringWithCString:buffer encoding:NSASCIIStringEncoding] uppercaseString];
}

// ----------------------------------------------------------------------------

/**
   This function serves two purposes, license verification and application dock icon pulsation
 
   The function processes the pulse dictionary in the following manner:
 
   TSK_KEY_PULSE_STATE = FAKE_PULSE_STATE_VALIDATE_STORED_LICENSE, TSK_KEY_PULSE_DATA is a NSData* and contains AquaticPrime's licenseData
   TSK_KEY_PULSE_STATE = FAKE_PULSE_STATE_VALIDATE_LICENSE_ENTRY, TSK_KEY_PULSE_DATA is a NSDictionary* and contains a license file's contents for processing by AquaticPrime
 
*/
- (void)performPulse:(NSDictionary*)aPulse
{	
	int pulseState = [[aPulse objectForKey:TSK_KEY_PULSE_STATE] intValue];
	
	if (pulseState == FAKE_PULSE_STATE_VALIDATE_STORED_LICENSE || pulseState == FAKE_PULSE_STATE_VALIDATE_LICENSE_ENTRY) {
		
		NSDictionary* licenseDict = [aPulse objectForKey:TSK_KEY_PULSE_DATA];
		
		if (licenseDict && [licenseDict count] == 2) {
			NSString* generatedLicenseCode = [self currentPulseStatus:[licenseDict objectForKey:TSK_LICENSE_KEY_USERNAME]];
			NSString* givenLicenseCode = [licenseDict objectForKey:TSK_LICENSE_KEY_NUMBER];
			
			if ([generatedLicenseCode isEqualToString:givenLicenseCode]) {
				markChar = VALID_LICENSE_BYTE1;
			}
			if ([generatedLicenseCode isEqualToString:givenLicenseCode]) {
				modder = VALID_LICENSE_BYTE2;
			}
		}
		
		if (markChar != VALID_LICENSE_BYTE1 && VALID_LICENSE_BYTE2 != modder && pulseState == FAKE_PULSE_STATE_VALIDATE_STORED_LICENSE) {
			[self performSelector:@selector(displayLicenseStatus:) withObject:nil afterDelay:((random() % 2) + 1)];
		}
		else if (pulseState == FAKE_PULSE_STATE_VALIDATE_LICENSE_ENTRY) {
			[self performSelector:@selector(updateDefaultPreferences:) withObject:licenseDict afterDelay:0];
			[self performSelector:@selector(displayLicenseStatus:) withObject:nil afterDelay:((random() % 2) + 1)];
		}
		if (VALID_LICENSE_BYTE2 == modder && markChar == VALID_LICENSE_BYTE1) {
			registeredUserName = [[NSString alloc] initWithString:[licenseDict objectForKey:TSK_LICENSE_KEY_USERNAME]];
		}
	}
}

// ----------------------------------------------------------------------------

+ (void)initialize
{
	srandom(time(NULL));
	
	if (self == [TSKAppController class]) {
		[self registerDefaultPreferences];
	}
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[prefsWindowController release];
	[aboutWindowController release];
	[registeredUserName release];
	
	[super dealloc];
}

// ----------------------------------------------------------------------------

-(BOOL)doesUserAgreeToEndUserLicenseAgreement
{
	TSKEULAWindowController* controller = [[TSKEULAWindowController alloc] initWithWindowNibName:@"EULA"];
	[[controller window] center];
	[[controller window] makeKeyAndOrderFront:self];		
	
	BOOL doesAgree = (NSOKButton == [NSApp runModalForWindow:[controller window]]);
	[controller release];
	
	return doesAgree;
}

// ----------------------------------------------------------------------------

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary* dict = [defaults objectForKey:TSK_KEY_LICENSE];
	
	if ([dict count] == 0) {
		if (NO == [self doesUserAgreeToEndUserLicenseAgreement]) {
			exit(-1);
		}
		else {
			NSDictionary* fakeLicenseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"", TSK_LICENSE_KEY_NUMBER, @"", TSK_LICENSE_KEY_USERNAME, nil];
			[self updateDefaultPreferences:fakeLicenseDict];
		}
	}
	
	NSNumber* fakePulseState = [NSNumber numberWithInt:FAKE_PULSE_STATE_VALIDATE_STORED_LICENSE];

	[self newMenuItemSelected:self];
	
	NSDictionary* licenseDict = [[NSUserDefaults standardUserDefaults] objectForKey:TSK_KEY_LICENSE];
		
	NSDictionary* fakePulse = [NSDictionary dictionaryWithObjectsAndKeys:fakePulseState, TSK_KEY_PULSE_STATE,
							   licenseDict, TSK_KEY_PULSE_DATA,
							   nil];
	
	[self performSelector:@selector(performPulse:) withObject:fakePulse afterDelay:0];
}

// ----------------------------------------------------------------------------

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
}

// ----------------------------------------------------------------------------



- (IBAction)aboutMenuItemSelected:(id)sender
{
	if (aboutWindowController == nil) {
		aboutWindowController = [[TSKAboutWindowController alloc] initWithWindowNibName:@"AboutDialog"];
	}
	if (NO == [[aboutWindowController window] isVisible]) {
		[[aboutWindowController window] makeKeyAndOrderFront:self];
	}
}

// ----------------------------------------------------------------------------

- (IBAction)prefsMenuItemSelected:(id)sender
{
	if (prefsWindowController == nil) {
		prefsWindowController = [[TSKPrefsWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
	}
	if (NO == [[prefsWindowController window] isVisible]) {
		[[prefsWindowController window] makeKeyAndOrderFront:self];
	}
}

// ----------------------------------------------------------------------------

- (void)registerMenuItemSelected:(id)sender
{
	TSKRegisterDialogController* controller = [[TSKRegisterDialogController alloc] init];
	[[controller window] center];
	[[controller window] makeKeyAndOrderFront:self];		
	
	if (NSOKButton == [NSApp runModalForWindow:[controller window]]) {		
		NSDictionary* fakePulse = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:FAKE_PULSE_STATE_VALIDATE_LICENSE_ENTRY], TSK_KEY_PULSE_STATE,
								   [controller data], TSK_KEY_PULSE_DATA,
								   nil];
		
		[self performSelector:@selector(performPulse:) withObject:fakePulse afterDelay:0];		
	}
	[controller release];
	
}

- (BOOL)isRegisterMenuItemSelected
{
	return (VALID_LICENSE_BYTE1 != markChar || VALID_LICENSE_BYTE2 != modder);
}

// ----------------------------------------------------------------------------

- (void)displayLicenseStatus:(id)sender
{		
	if (VALID_LICENSE_BYTE1 != markChar || VALID_LICENSE_BYTE2 != modder) {

		TSKLicenseDialogController* controller = [[TSKLicenseDialogController alloc] init];
		[[controller window] center];
		[[controller window] makeKeyAndOrderFront:self];		
		
		int licenseDialogResult = [NSApp runModalForWindow:[controller window]];
		if (NSOKButton == licenseDialogResult) {
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://localhost/~lyndsey/taskation.html"]]; 
		}
		else if (NSAlertOtherReturn == licenseDialogResult) {
			[self registerMenuItemSelected:nil];
		}
		[controller release];
	}
	else {
		NSRunAlertPanel(NSLocalizedString(@"LicenseDialogAlertString", nil), /*title*/
						NSLocalizedString(@"LicenseDialogThankYouString", nil), /*message*/
						NSLocalizedString(@"LicenseDialogOKButtonString", nil), /*default button*/
						nil, nil);
	}
}

// ----------------------------------------------------------------------------

- (IBAction)newMenuItemSelected:(id)sender
{
	TSKDocWindowController* docController = [[TSKDocWindowController alloc] initWithWindowNibName:@"DocumentWindow"];
	[docController showWindow:self];
}

// ----------------------------------------------------------------------------

- (IBAction)openMenuItemSelected:(id)sender
{
	TSKDocWindowController* docController = [[TSKDocWindowController alloc] initWithWindowNibName:@"DocumentWindow"];
	[docController openDocument];
}

// ----------------------------------------------------------------------------

- (void)appendRecentFileURL:(NSURL*)recentFileURL
{	
	NSDocumentController* documentController = [NSDocumentController sharedDocumentController];
	NSMutableArray* recentDocumentURLs = [[documentController recentDocumentURLs] mutableCopy];
	if ([recentDocumentURLs count] > 9)  {
		[recentDocumentURLs removeObjectAtIndex:0];
		[documentController clearRecentDocuments:self];
		for (NSURL* documentURL in recentDocumentURLs) {
			[documentController noteNewRecentDocumentURL:documentURL];
		}
	}
	[recentDocumentURLs release];
	[documentController noteNewRecentDocumentURL:recentFileURL];
}

// ----------------------------------------------------------------------------

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	for (NSString* filePath in filenames) {
		NSString* fileExtension = [filePath pathExtension];

		if ([fileExtension compare:TSK_DOCUMENT_FILENAME_EXTENSION] == NSOrderedSame) {
			TSKDocWindowController* docController = [[TSKDocWindowController alloc] initWithWindowNibName:@"DocumentWindow"];
			[docController openFile:filePath];
		}
	}
}
@end
