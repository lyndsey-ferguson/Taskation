//
//  TSKLicenseDialogController.m
//  Taskation
//
//  Created by Lyndsey on 4/2/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKLicenseDialogController.h"

static 	BOOL gIsFirstNotice = YES;

@implementation TSKLicenseDialogController

- (id)init
{
	return [super initWithWindowNibName:@"LicenseDialog"];
}

// ----------------------------------------------------------------------------

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	if (gIsFirstNotice) {
		[adviceText setStringValue:NSLocalizedString(@"UnlicensedDialogAdviceString_FirstNotice", nil)];		
	}
	else {
		[adviceText setStringValue:NSLocalizedString(@"UnlicensedDialogAdviceString_SubsequentNotice", nil)];		
	}
}

// ----------------------------------------------------------------------------

- (IBAction)purchaseButtonClicked:(id)sender
{
	gIsFirstNotice = NO;

	[NSApp stopModalWithCode:NSOKButton];
	[[self window] orderOut:self];

}

// ----------------------------------------------------------------------------

- (IBAction)useUnlicensedButtonClicked:(id)sender
{
	gIsFirstNotice = NO;

	[NSApp stopModalWithCode:NSCancelButton];
	[[self window] orderOut:self];

}

// ----------------------------------------------------------------------------

- (IBAction)registerLicenseButtonClicked:(id)sender
{
	gIsFirstNotice = NO;
	[NSApp stopModalWithCode:NSAlertOtherReturn];
	[[self window] orderOut:self];
}

@end
