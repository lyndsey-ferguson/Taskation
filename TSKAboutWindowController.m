//
//  TSKAboutWindowController.m
//  Taskation
//
//  Created by Lyndsey on 4/1/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKAboutWindowController.h"
#import "TSKAppController.h"

@implementation TSKAboutWindowController

- (void)windowDidLoad
{
	NSString* formatString = NSLocalizedString(@"VersionLabelString", nil);
	
	NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
	
	NSString* versionLabelString = [NSString stringWithFormat:formatString, [infoDictionary objectForKey:@"CFBundleVersion"]];
	[versionTextField setStringValue:versionLabelString];
	
	TSKAppController* appController = [NSApp delegate];
	
	NSString* registeredUserName = [appController registeredUserName];
	if (!registeredUserName) {
		registeredUserName = @"-";
	}
	[registeredUserTextField setStringValue:registeredUserName];
	[registeredUserTextField sizeToFit];
	[registeredUserTextLabel sizeToFit];
	
	NSRect contentRect = [[[self window] contentView] frame];
	NSRect labelRect = [registeredUserTextLabel frame];
	NSRect fieldRect = [registeredUserTextField frame];
	
	CGFloat horizontalCoord_Label = (contentRect.size.width - (labelRect.size.width + fieldRect.size.width))/2;
	CGFloat horizontalCoord_Field = horizontalCoord_Label + labelRect.size.width;
	
	labelRect.origin.x = horizontalCoord_Label;
	fieldRect.origin.x = horizontalCoord_Field;
	
	[registeredUserTextLabel setFrame:labelRect];
	[registeredUserTextField setFrame:fieldRect];
	
	[registeredUserTextLabel setNeedsDisplay];
	[registeredUserTextField setNeedsDisplay];
}

@end
