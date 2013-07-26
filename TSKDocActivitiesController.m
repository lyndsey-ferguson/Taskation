//
//  TSKDocActivitiesController.m
//  Taskation
//
//  Created by Lyndsey on 12/16/08.
//  Copyright 2008 Lyndsey D. Ferguson. All rights reserved.
//


#import "TSKDocWindowController.h"
#import "TSKNotesViewController.h"

@implementation TSKDocWindowController (ActivitiesTable)

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSIndexSet* selectedIndexes = [(NSTableView*)[aNotification object] selectedRowIndexes];
	
	if (nil != notesViewController) {
		if ([selectedIndexes count] > 1) {
			[notesViewController displayMultipleNotesState];
		}
		else if ([selectedIndexes count] == 0 || 0 == [activities count]) {
			[notesViewController displayNoNotesState];
		}
		else {
			[notesViewController displayActivityNotes:[[arrayController selectedObjects] objectAtIndex:0]];
		}
	}
}

@end
