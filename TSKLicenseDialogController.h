//
//  TSKLicenseDialogController.h
//  Taskation
//
//  Created by Lyndsey on 4/2/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TSKLicenseDialogController : NSWindowController {
	IBOutlet NSTextField* adviceText;
}

- (id)init;
- (IBAction)purchaseButtonClicked:(id)sender;
- (IBAction)useUnlicensedButtonClicked:(id)sender;
- (IBAction)registerLicenseButtonClicked:(id)sender;

@end
