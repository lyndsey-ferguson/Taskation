//
//  TSKEULAWindowController.h
//  Taskation
//
//  Created by Lyndsey on 2/11/10.
//  Copyright 2010 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TSKEULAWindowController : NSWindowController {
	IBOutlet NSTextView* eulaTextView;
}

- (IBAction)agreeButtonClicked:(id)sender;
- (IBAction)disagreeButtonClicked:(id)sender;

@end
