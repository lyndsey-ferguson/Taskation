//
//  TSKRegisterDialogController.m
//  Taskation
//
//  Created by Lyndsey on 2/8/10.
//  Copyright 2010 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKRegisterDialogController.h"
#import "TSKAppController.h"
#import "TSKLicenseKeyComponentFormatter.h"

@implementation TSKRegisterDialogController

- (id)init
{
	licenseKeyComponentFormatter = [[TSKLicenseKeyComponentFormatter alloc] init];
	
	return [super initWithWindowNibName:@"RegisterDialog"];
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[licenseKeyComponentFormatter release];
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (void)windowDidLoad
{
	[licenseKeyTextField1 setFormatter:licenseKeyComponentFormatter];
	[licenseKeyTextField2 setFormatter:licenseKeyComponentFormatter];
	[licenseKeyTextField3 setFormatter:licenseKeyComponentFormatter];
	[licenseKeyTextField4 setFormatter:licenseKeyComponentFormatter];
	[licenseKeyTextField5 setFormatter:licenseKeyComponentFormatter];

	[licenseKeyTextField1 setStringValue:@""];
	[licenseKeyTextField2 setStringValue:@""];
	[licenseKeyTextField3 setStringValue:@""];
	[licenseKeyTextField4 setStringValue:@""];
	[licenseKeyTextField5 setStringValue:@""];
	
	NSNumber* value = [NSNumber numberWithBool:NO];
	NSString* key = [[NSNumber numberWithUnsignedInteger:[licenseKeyTextField1 hash]] stringValue];
	
	validLicenseComponentsDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
	[validLicenseComponentsDictionary setValue:value forKey:key];
	
	key = [[NSNumber numberWithUnsignedInteger:[licenseKeyTextField2 hash]] stringValue];
	[validLicenseComponentsDictionary setValue:value forKey:key];
	
	key = [[NSNumber numberWithUnsignedInteger:[licenseKeyTextField3 hash]] stringValue];
	[validLicenseComponentsDictionary setValue:value forKey:key];
	
	key = [[NSNumber numberWithUnsignedInteger:[licenseKeyTextField4 hash]] stringValue];
	[validLicenseComponentsDictionary setValue:value forKey:key];
	
	key = [[NSNumber numberWithUnsignedInteger:[licenseKeyTextField5 hash]] stringValue];
	[validLicenseComponentsDictionary setValue:value forKey:key];
}
// ----------------------------------------------------------------------------

- (NSDictionary*)data
{
	NSString* enteredLicensedOwner = [licenseOwnerTextField stringValue];
	NSString* enteredLiceneseNumber = [NSString stringWithFormat:@"%@-%@-%@-%@-%@", [licenseKeyTextField1 stringValue],
																				    [licenseKeyTextField2 stringValue],
																				    [licenseKeyTextField3 stringValue],
																				    [licenseKeyTextField4 stringValue],
																				    [licenseKeyTextField5 stringValue]];
	
	NSDictionary* theLicenseData = [NSDictionary dictionaryWithObjectsAndKeys:enteredLicensedOwner, TSK_LICENSE_KEY_USERNAME, [enteredLiceneseNumber uppercaseString], TSK_LICENSE_KEY_NUMBER, nil];

	return theLicenseData;
}

// ----------------------------------------------------------------------------

- (IBAction)registerButtonClicked:(id)sender
{
	TSKAppController* appController = [NSApp delegate];
	
	NSDictionary* licenseDict = [self data];
	NSString* correspondingSerialNumber = [appController currentPulseStatus:[licenseDict objectForKey:TSK_LICENSE_KEY_USERNAME]];
	NSString* givenSerialNumber = [licenseDict objectForKey:TSK_LICENSE_KEY_NUMBER];
	
	if ([correspondingSerialNumber isEqualToString:givenSerialNumber]) {
		[NSApp stopModalWithCode:NSOKButton];
	}
	else {
		NSBeep();
	}
}

// ----------------------------------------------------------------------------

- (IBAction)cancelButtonClicked:(id)sender
{
	[NSApp stopModalWithCode:NSCancelButton];
}

// ----------------------------------------------------------------------------

- (void)controlTextDidChange:(NSNotification*)notification
{
	NSTextField* textField = [notification object];
	
	if (textField != licenseOwnerTextField) {
		BOOL isLicenseKeyComponentComplete = ([[textField stringValue] length] == 4);
		
		NSNumber* value = [NSNumber numberWithBool:isLicenseKeyComponentComplete];
		NSString* key = [[NSNumber numberWithUnsignedInteger:[textField hash]] stringValue];
		
		[validLicenseComponentsDictionary setValue:value
											forKey:key];
		
		if (isLicenseKeyComponentComplete) {
			[[self window] makeFirstResponder:[(NSTextField*)[notification object] nextKeyView]];
		}
	}
	
	[registerButton setEnabled:[self isRegisterButtonEnabled]];
}

// ----------------------------------------------------------------------------

- (BOOL)isRegisterButtonEnabled
{
	BOOL haveAllLicenseKeyComponents = ([[licenseOwnerTextField stringValue] length] > 0);
	
	for (NSNumber* licenseComponentValue in [validLicenseComponentsDictionary allValues]) {
		haveAllLicenseKeyComponents = [licenseComponentValue boolValue]  && haveAllLicenseKeyComponents;
	}
	
	return haveAllLicenseKeyComponents;
}


@end