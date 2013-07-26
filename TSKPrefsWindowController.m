//
//  ActionSubjectWindowController.m
//  Taskation
//
//  Created by Lyndsey on 1/26/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKPrefsWindowController.h"
#import "TSKDefinitions.h"
#import "TSKDefinitionsViewController.h"

@implementation TSKPrefsWindowController

- (id)initWithWindowNibName:(NSString*)nibName
{
	self = [super initWithWindowNibName:nibName];
	if (self) {
		TSKDefinitions* definitions = [[TSKDefinitions alloc] init];
		definitionsViewController = [[TSKDefinitionsViewController alloc] initWithDefinitions:definitions];
		[definitionsViewController loadView];
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)windowDidLoad
{
	[definitionsSuperview addSubview:[definitionsViewController view]];
	
	NSRect superViewFrame = [definitionsSuperview frame];
	NSRect viewFrame = [[definitionsViewController view] frame];
	viewFrame.origin.x = 17;
	viewFrame.origin.y = 17;
	viewFrame.size.width = superViewFrame.size.width - 34;
	viewFrame.size.height = superViewFrame.size.height - 20;
	
	[[definitionsViewController view] setFrame:viewFrame];
	
	[definitionsSuperview setNeedsDisplay:YES];
}

// ----------------------------------------------------------------------------

- (void)windowWillClose:(NSNotification *)notification
{
	NSDictionary* defaultActions = [[definitionsViewController definitions] actions];
	NSDictionary* defaultSubjects = [[definitionsViewController definitions] subjects];
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:defaultActions forKey:TSK_KEY_ACTIONS];
	[defaults setObject:defaultSubjects forKey:TSK_KEY_SUBJECTS];	
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[definitionsViewController release];
	[super dealloc];
}
@end
