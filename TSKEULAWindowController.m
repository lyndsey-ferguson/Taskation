//
//  TSKEULAWindowController.m
//  Taskation
//
//  Created by Lyndsey on 2/11/10.
//  Copyright 2010 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKEULAWindowController.h"


@implementation TSKEULAWindowController

- (void)windowDidLoad
{
	NSString* eulaTextFilePath = [[NSBundle mainBundle] pathForResource:@"EULA" ofType:@"rtf"];
	
/*
 NSAttributedString* eulaText = [[NSAttributedString alloc] initWithPath:eulaTextFilePath
														  documentAttributes:NULL];
*/		
	[eulaTextView readRTFDFromFile:eulaTextFilePath];
}

// ----------------------------------------------------------------------------

- (IBAction)agreeButtonClicked:(id)sender
{
	[NSApp stopModalWithCode:NSOKButton];
}

// ----------------------------------------------------------------------------

- (IBAction)disagreeButtonClicked:(id)sender
{
	[NSApp stopModalWithCode:NSCancelButton];
}

@end
