//
//  TSKDocDefinitionsWindowController.m
//  Taskation
//
//  Created by Lyndsey on 4/1/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKDocDefinitionsWindowController.h"
#import "TSKDefinitionsViewController.h"

@implementation TSKDocDefinitionsWindowController

- (id)initWithDefinitions:(TSKDefinitions*)theDefinitions
{
	self = [super initWithWindowNibName:@"DocDefinitionsWindow"];
	if (self) {
		definitionsViewController = [[TSKDefinitionsViewController alloc] initWithDefinitions:theDefinitions];
		[definitionsViewController loadView];
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[definitionsViewController release];
	[super dealloc];
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
	
	NSSize windowMaxSize = [[self window] frame].size;
	windowMaxSize.height = FLT_MAX;
	[[self window] setMaxSize:windowMaxSize];
	[definitionsSuperview setNeedsDisplay:YES];
}

// ----------------------------------------------------------------------------

- (IBAction)okButtonClicked:(id)sender
{
	[NSApp stopModalWithCode:NSOKButton];
	[[self window] orderOut:self];
}

// ----------------------------------------------------------------------------

- (IBAction)cancelButtonClicked:(id)sende
{
	[NSApp stopModalWithCode:NSCancelButton];
	[[self window] orderOut:self];
}

@end
