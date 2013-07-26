//
//  TSKRegisterDialogController.h
//  Taskation
//
//  Created by Lyndsey on 2/8/10.
//  Copyright 2010 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKLicenseKeyComponentFormatter;

@interface TSKRegisterDialogController : NSWindowController {
	IBOutlet NSTextField* licenseOwnerTextField;
	IBOutlet NSTextField* licenseKeyTextField1;
	IBOutlet NSTextField* licenseKeyTextField2;
	IBOutlet NSTextField* licenseKeyTextField3;
	IBOutlet NSTextField* licenseKeyTextField4;
	IBOutlet NSTextField* licenseKeyTextField5;
	IBOutlet NSButton*	  registerButton;
	
	NSMutableDictionary* validLicenseComponentsDictionary;
	
	TSKLicenseKeyComponentFormatter* licenseKeyComponentFormatter;
}

- (id)init;
- (IBAction)registerButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

- (BOOL)isRegisterButtonEnabled;
- (NSDictionary*)data;

@end
