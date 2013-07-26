//
//  TSKActivityDefsViewController.m
//  Taskation
//
//  Created by Lyndsey on 3/31/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKDefinitionsViewController.h"
#import "TSKDefinitions.h"

#define TSKActionsTableViewDataType @"com.taskation.actions.tableview.datatype"

extern unsigned char modder;

@implementation TSKDefinitionsViewController

@synthesize definitions;

- (id)initWithDefinitions:(TSKDefinitions*)theDefinitions
{
	self = [super initWithNibName:@"DefinitionsView" bundle:nil];
	if (self) {
		definitions = [theDefinitions retain];
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[definitions release];
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (void)awakeFromNib
{
	[self setActionSubjectInitialState];
}

// ----------------------------------------------------------------------------

- (NSString*)selectedAction
{
	NSString* action = nil;
	
	NSIndexSet* actionIndexes = [actionsTableView selectedRowIndexes];
	if ([actionIndexes count] > 0) {
		
		NSUInteger selectedIndex = [actionIndexes firstIndex];
		
		BOOL isUniqueAction = (selectedIndex > 0);
		if (isUniqueAction) {			
			action = [definitions actionAtIndex:(selectedIndex - 1)];
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
			actionID = [definitions actionIDForActionAtIndex:(selectedIndex - 1)];
		}
	}
	return actionID;
}

// ----------------------------------------------------------------------------

- (IBAction)addActionButtonClicked:(id)sender
{	
	NSString* uuid = [definitions addAction:TSK_TABLEVIEW_EMPTY_STRING];
	[actionsTableView reloadData];
	
	int index = [definitions indexForActionID:uuid] + 1;
	[actionsTableView selectRow:index byExtendingSelection:NO];
	[actionsTableView editColumn:0 row:index withEvent:nil select:YES];
}

// ----------------------------------------------------------------------------

- (IBAction)removeActionButtonClicked:(id)sender
{
	if ([definitions removeActionAtIndex:([[actionsTableView selectedRowIndexes] firstIndex] - 1)]) {
		NSUInteger indexOfActionToRemove = [[actionsTableView selectedRowIndexes] firstIndex];
	
		[actionsTableView reloadData];
		
		NSUInteger actionCount = [[definitions actions] count];
		if (indexOfActionToRemove > actionCount) {
			indexOfActionToRemove = actionCount;
		}
		if (indexOfActionToRemove >= 0) {
			[actionsTableView selectRow:indexOfActionToRemove byExtendingSelection:NO];
		}
		
	}
}

// ----------------------------------------------------------------------------

- (IBAction)addSubjectButtonClicked:(id)sender
{	
	if (VALID_LICENSE_BYTE2 == modder || (VALID_LICENSE_BYTE2 != modder && ([definitions subjectCountForAction:TSK_ACTION_ALL_SUBJECTS] < INVALID_MAXIMUM_SUBJECTS))) {
		NSString* subjectID = [definitions addSubject:TSK_TABLEVIEW_EMPTY_STRING];
		NSString* actionID = [self selectedActionID];
		if (actionID) {
			[definitions associateSubject:subjectID withAction:actionID];
		}
		[subjectsTableView reloadData];
		NSUInteger rowIndex = [definitions indexOfSubjectID:subjectID forActionID:actionID];
		[subjectsTableView selectRow:rowIndex byExtendingSelection:NO];
		[subjectsTableView editColumn:0 row:rowIndex withEvent:nil select:YES];
	}
	else {
		NSBeep();
		[[NSApp delegate] performSelector:@selector(displayLicenseStatus:) withObject:nil];
	}
}

// ----------------------------------------------------------------------------

- (IBAction)removeSubjectButtonClicked:(id)sender
{
	NSUInteger indexOfSubjectToRemove = [[subjectsTableView selectedRowIndexes] firstIndex];
	NSString* actionID = [self selectedActionID];
	[definitions removeSubjectAtIndex:indexOfSubjectToRemove forActionID:actionID];

	[subjectsTableView reloadData];
	
	NSUInteger subjectCount = [[definitions subjects] count];
	if (indexOfSubjectToRemove > subjectCount - 1) {
		indexOfSubjectToRemove = subjectCount - 1;
	}
	if (indexOfSubjectToRemove >= 0) {
		[subjectsTableView selectRow:indexOfSubjectToRemove byExtendingSelection:NO];
	}
}

// ----------------------------------------------------------------------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{	
	NSInteger rowCount = 0; 
	
	if (actionsTableView == tableView) {
		rowCount = 1 + [definitions actionCount]; // There is the option for all actions
	}
	else if (subjectsTableView == tableView) {
		rowCount = [definitions subjectCountForAction:[self selectedAction]];
	}
	
	return rowCount;
}

// ----------------------------------------------------------------------------

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSString* rowString = nil;
	
	if (actionsTableView == tableView) {
		if (0 == row) {
			rowString = NSLocalizedString(@"AllSubjectsActionPlaceholder", nil);
		}
		else {
			rowString = [definitions actionAtIndex:(row - 1)];
		}
	}
	else if (subjectsTableView == tableView) {
		rowString = [definitions subjectAtIndex:row forAction:[self selectedAction]];
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
	
	if ([(NSString*)object length] > 0) {
		BOOL isSpecificAction = (row > 0);
		
		if (actionsTableView == tableView && isSpecificAction) {
			[definitions setAction:object atIndex:(row - 1)];
		}
		else if (subjectsTableView == tableView) {
			[definitions setSubject:object atIndex:row forActionID:[self selectedActionID]];
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
		NSString* subject = [definitions subjectAtIndex:[rowIndexes firstIndex] forAction:[self selectedAction]];
		
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[definitions subjectIDForSubject:subject]];
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
		
		NSString* actionID = [definitions actionIDForActionAtIndex:(row - 1)];
		[definitions associateSubject:subjectID withAction:actionID];
		
		acceptedDrop = YES;
	}
	return acceptedDrop;
	
}

// ----------------------------------------------------------------------------

- (void)tableView:(NSTableView*)tableView deleteRows:(NSIndexSet*)selectedRows
{
	if (actionsTableView == tableView) {
		if (0 < [[actionsTableView selectedRowIndexes] firstIndex]) {
			[self removeActionButtonClicked:self];
		}
	}
	else if (subjectsTableView == tableView) {
		[self removeSubjectButtonClicked:self];
	}
}

@end
