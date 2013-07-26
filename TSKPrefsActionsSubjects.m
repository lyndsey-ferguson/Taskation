//
//  TSKPrefsActionsSubjects.m
//  Taskation
//
//  Created by Lyndsey on 1/31/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKPrefsWindowController.h"
#import "TSKActionSubjectManager.h"

#define TSKActionsTableViewDataType @"com.taskation.actions.tableview.datatype"

@implementation TSKPrefsWindowController ( TSKActionsAndSubjects )

- (NSString*)selectedAction
{
	NSString* action = nil;
	
	NSIndexSet* actionIndexes = [actionsTableView selectedRowIndexes];
	if ([actionIndexes count] > 0) {
		
		NSUInteger selectedIndex = [actionIndexes firstIndex];
		
		BOOL isUniqueAction = (selectedIndex > 0);
		if (isUniqueAction) {
			TSKActionSubjectManager* asManager = [TSKActionSubjectManager sharedInstance];
			
			action = [asManager actionAtIndex:(selectedIndex - 1)];
		}
		else {
			action = TSK_ACTION_ALL_SUBJECTS;
		}
	}
	return action;
}

// ----------------------------------------------------------------------------

- (NSString*)selectedActionID
{
	NSString* actionID = nil;
	NSIndexSet* actionIndexes = [actionsTableView selectedRowIndexes];
	if ([actionIndexes count] > 0) {
		
		NSUInteger selectedIndex = [actionIndexes firstIndex];
		if (selectedIndex > 0) {
			TSKActionSubjectManager* asManager = [TSKActionSubjectManager sharedInstance];
			actionID = [asManager actionIDForActionAtIndex:(selectedIndex - 1)];
		}
	}
	return actionID;
}

// ----------------------------------------------------------------------------

- (IBAction)addActionButtonClicked:(id)sender
{
	TSKActionSubjectManager* asManager = [TSKActionSubjectManager sharedInstance];
	
	[asManager addAction:TSK_TABLEVIEW_EMPTY_STRING];
	[actionsTableView reloadData];
	[actionsTableView selectRow:[asManager actionCount] byExtendingSelection:NO];
	[actionsTableView editColumn:0 row:[asManager actionCount] withEvent:nil select:YES];
}

// ----------------------------------------------------------------------------

- (IBAction)removeActionButtonClicked:(id)sender
{
	TSKActionSubjectManager* asManager = [TSKActionSubjectManager sharedInstance];
	if ([asManager removeActionAtIndex:([[actionsTableView selectedRowIndexes] firstIndex] - 1)]) {
		[actionsTableView reloadData];
	}
	
}

- (IBAction)addSubjectButtonClicked:(id)sender
{
	TSKActionSubjectManager* asManager = [TSKActionSubjectManager sharedInstance];
	
	NSString* subjectID = [asManager addSubject:TSK_TABLEVIEW_EMPTY_STRING];
	NSString* actionID = [self selectedActionID];
	if (actionID) {
		[asManager associateSubject:subjectID withAction:actionID];
	}
	[subjectsTableView reloadData];
	NSUInteger rowIndex = [asManager indexOfSubjectID:subjectID forActionID:actionID];
	[subjectsTableView selectRow:rowIndex byExtendingSelection:NO];
	[subjectsTableView editColumn:0 row:rowIndex withEvent:nil select:YES];
}

// ----------------------------------------------------------------------------

- (IBAction)removeSubjectButtonClicked:(id)sender
{
	TSKActionSubjectManager* asManager = [TSKActionSubjectManager sharedInstance];
	NSUInteger indexOfSubjectToRemove = [[subjectsTableView selectedRowIndexes] firstIndex];
	[asManager removeSubjectAtIndex:indexOfSubjectToRemove forActionID:[self selectedActionID]];
	[subjectsTableView reloadData];
}

// ----------------------------------------------------------------------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	TSKActionSubjectManager* asManager = [TSKActionSubjectManager sharedInstance];
	
	NSInteger rowCount = 0; 
	
	if (actionsTableView == tableView) {
		rowCount = 1 + [asManager actionCount]; // There is the option for all actions
	}
	else if (subjectsTableView == tableView) {
		rowCount = [asManager subjectCountForAction:[self selectedAction]];
	}
	
	return rowCount;
}

// ----------------------------------------------------------------------------

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSString* rowString = nil;
	
	TSKActionSubjectManager* asManager = [TSKActionSubjectManager sharedInstance];

	if (actionsTableView == tableView) {
		if (0 == row) {
			rowString = NSLocalizedString(@"AllSubjectsActionPlaceholder", nil);
		}
		else {
			rowString = [asManager actionAtIndex:(row - 1)];
		}
	}
	else if (subjectsTableView == tableView) {
		rowString = [asManager subjectAtIndex:row forAction:[self selectedAction]];
	}
	
	return rowString;
}

// ----------------------------------------------------------------------------

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{		
	return !(actionsTableView == aTableView && rowIndex == 0);
}

// ----------------------------------------------------------------------------

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	TSKActionSubjectManager* asManager = [TSKActionSubjectManager sharedInstance];

	if ([(NSString*)object length] > 0) {
		BOOL isSpecificAction = (row > 0);
		
		if (actionsTableView == tableView && isSpecificAction) {
			[asManager setAction:object atIndex:(row - 1)];
		}
		else if (subjectsTableView == tableView) {
			[asManager setSubject:object atIndex:row forActionID:[self selectedActionID]];
		}
	}
	[tableView reloadData];
	
	return;
}

// ----------------------------------------------------------------------------

- (void)updateButtonsEnableState
{
	NSIndexSet* selectedActionIndexes = [actionsTableView selectedRowIndexes];
	
	BOOL enableActionRemoveButton = (0 < [selectedActionIndexes count] && (0 != [selectedActionIndexes firstIndex]));
	BOOL enableSubjectRemoveButton = (0 < [[subjectsTableView selectedRowIndexes] count]);
	BOOL enableSubjectAddButton = (0 < [selectedActionIndexes count]);
	
	[removeActionButton setEnabled:enableActionRemoveButton];
	[addSubjectButton setEnabled:enableSubjectAddButton];
	[removeSubjectButton setEnabled:enableSubjectRemoveButton];	
}

// ----------------------------------------------------------------------------

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSTableView* changedTableView = [aNotification object];
	
	[self updateButtonsEnableState];
	
	if (actionsTableView == changedTableView) {
		[subjectsTableView reloadData];
	}
	
	return;
}

// ----------------------------------------------------------------------------

- (void)setActionSubjectInitialState
{
	[actionsTableView selectRow:0 byExtendingSelection:NO];
	[actionsTableView registerForDraggedTypes:[NSArray arrayWithObject:TSKActionsTableViewDataType]];
	[subjectsTableView registerForDraggedTypes:[NSArray arrayWithObject:TSKActionsTableViewDataType]];
	
	[self updateButtonsEnableState];
}

// ----------------------------------------------------------------------------

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	BOOL canDrag = NO;
	
	if (subjectsTableView == aTableView) {
		TSKActionSubjectManager* asMgr = [TSKActionSubjectManager sharedInstance];
		
		NSString* subject = [asMgr subjectAtIndex:[rowIndexes firstIndex] forAction:[self selectedAction]];
		
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[asMgr subjectIDForSubject:subject]];
		[pboard declareTypes:[NSArray arrayWithObject:TSKActionsTableViewDataType] owner:self];
		[pboard setData:data forType:TSKActionsTableViewDataType];
		
		canDrag = YES;
	}
	
	return canDrag;
}

// ----------------------------------------------------------------------------

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
	NSDragOperation dropOp = NSDragOperationNone;
	
	if (tv == actionsTableView && 0 != row && op != NSTableViewDropAbove) {
		dropOp = NSDragOperationLink;
	}
	
	return dropOp;
}

// ----------------------------------------------------------------------------

- (BOOL)tableView:(NSTableView *)aTableView
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)operation
{
	BOOL acceptedDrop = NO;
	
	if (actionsTableView == aTableView) {
		NSPasteboard* pboard = [info draggingPasteboard];
		NSData* rowData = [pboard dataForType:TSKActionsTableViewDataType];
		
		NSString* subjectID = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
		
		TSKActionSubjectManager* asManager = [TSKActionSubjectManager sharedInstance];
		
		NSString* actionID = [asManager actionIDForActionAtIndex:(row - 1)];
		[asManager associateSubject:subjectID withAction:actionID];
		
		acceptedDrop = YES;
	}
	return acceptedDrop;
	
}
@end
