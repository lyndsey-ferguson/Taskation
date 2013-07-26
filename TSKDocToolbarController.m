//
//  TSKDocWindowToolBarController.m
//  Taskation
//
//  Created by Lyndsey on 10/16/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import "TSKDocWindowController.h"

NSString* kActivityControlsToolbarIdentifier = @"Activity Controls Toolbar Item";
static NSString* kActivitySearchToolbarIdentifier = @"Activity Search Toolbar Item";
static NSSize kActivityControlsToolbarMinSize = { 352, 54 };

@implementation  TSKDocWindowController (DocumentToolbar)

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
	 itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem* toolbarItem = nil;
	
	if ([itemIdentifier isEqual:kActivityControlsToolbarIdentifier]) {
		toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:kActivityControlsToolbarIdentifier];
		[toolbarItem setLabel:@"Activity Controls"];
		[toolbarItem setPaletteLabel:[toolbarItem label]];
		[toolbarItem setToolTip:@"Start and Stop Recording an activity"];
		[toolbarItem setView:[consoleViewController view]];
		[toolbarItem setMinSize:kActivityControlsToolbarMinSize];
		[toolbarItem setMaxSize:NSMakeSize(FLT_MAX, kActivityControlsToolbarMinSize.height)];
	}
	else if ([itemIdentifier isEqual:kActivitySearchToolbarIdentifier]) {
		if (nil == searchField) {
			NSRect searchFieldFrame = NSMakeRect(0, 0, 80, kActivityControlsToolbarMinSize.height);
			searchField = [[NSSearchField alloc] initWithFrame:searchFieldFrame];
			[searchField setContinuous:NO];
			[searchField setTarget:self];
			[searchField setAction:@selector(searchFieldChanged:)];
		}
		
		toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:kActivitySearchToolbarIdentifier];
		[toolbarItem setLabel:@"Search Activities"];
		[toolbarItem setPaletteLabel:[toolbarItem label]];
		[toolbarItem setToolTip:@"Search activities for a given value"];
		[toolbarItem setView:searchField];
		[toolbarItem setMinSize:NSMakeSize(80, 22)];
		[toolbarItem setMaxSize:NSMakeSize(FLT_MAX, kActivityControlsToolbarMinSize.height)];		
	}
	
	return [toolbarItem autorelease];
}

// ----------------------------------------------------------------------------

- (void)handleConsoleViewChange:(NSNotification*)notification
{
	NSToolbarSizeMode sizeMode = [toolbar sizeMode];
	if (sizeMode != [consoleViewController sizeMode]) {
		[consoleViewController setSizeMode:sizeMode];
		
		NSControlSize controlSize = 0;
		CGFloat height = 0;
		
		if (NSToolbarSizeModeRegular == sizeMode) {
			controlSize = NSSmallControlSize;
			height = 19.0;
		}
		else {
			controlSize = NSMiniControlSize;
			height = 12.0;
		}
		
		[[searchField cell] setControlSize:controlSize];
		[searchField setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:controlSize]]];
		
		NSRect searchFrame = [searchField frame];
		searchFrame.size.height = height;

		[searchField setFrame:searchFrame];
		[searchField setNeedsDisplay];
	}
}

// ----------------------------------------------------------------------------

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{	
	return [NSArray arrayWithObjects:NSToolbarFlexibleSpaceItemIdentifier,
			kActivityControlsToolbarIdentifier,
			kActivitySearchToolbarIdentifier,
			NSToolbarFlexibleSpaceItemIdentifier,
			NSToolbarSpaceItemIdentifier,
			NSToolbarSeparatorItemIdentifier,
			NSToolbarShowColorsItemIdentifier,
			NSToolbarShowFontsItemIdentifier,
			NSToolbarPrintItemIdentifier,
			nil];
}

// ----------------------------------------------------------------------------

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:NSToolbarFlexibleSpaceItemIdentifier, 
			kActivityControlsToolbarIdentifier,
			NSToolbarFlexibleSpaceItemIdentifier,
			kActivitySearchToolbarIdentifier,
			nil];
}

// ----------------------------------------------------------------------------

- (void)toolbarWillAddItem:(NSNotification *)notification
{
	
}

// ----------------------------------------------------------------------------

@end
