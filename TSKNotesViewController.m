//
//  TSKActivityNotesViewController.m
//  Taskation
//
//  Created by Lyndsey on 11/5/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import "TSKNotesViewController.h"
#import "TSKActivity.h"

@interface NSObject (TSKTableViewDelegate)
- (void)tableView:(NSTableView*)tableView deleteRows:(NSIndexSet*)selectedRows;
@end

@implementation TSKTableView

- (void)keyDown:(NSEvent *)event;
{
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	if ((key == NSDeleteCharacter) && [[self delegate] respondsToSelector:@selector(tableView:deleteRows:)]) {
		if ([self selectedRow] == -1) {
			NSBeep();
		}
		else {
			[[self delegate] tableView:self deleteRows:[self selectedRowIndexes]];
		}
		
	}
	else {
		[super keyDown:event];
	}	
}

@end

@implementation TSKNotesViewController

- (id)initWithNibName:(NSString*)nibName
			   bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibName bundle:nibBundleOrNil];
	
	currentActivity = nil;
	
	return self;
}

// ----------------------------------------------------------------------------

- (void)viewDidLoad
{
	[tableView setDataSource:self];
	[self displayNoNotesState];
}

// ----------------------------------------------------------------------------

- (IBAction)addButtonClicked:(id)sender
{
	
	if (currentActivity != nil) {
		NSString* note = [[NSString alloc] init];
		[[currentActivity notes] addObject:note];
		[tableView reloadData];
	}	
}

// ----------------------------------------------------------------------------

- (void)removeRows:(NSIndexSet*)rowsToRemove
{
	NSUInteger indexCount = [rowsToRemove count]; 
	if (0 < indexCount) {
		NSArray* notesCopy = [[currentActivity notes] copy];
		
		NSUInteger* indexes = (NSUInteger*) malloc(sizeof(NSUInteger) * indexCount);
		if (indexes) {
			[rowsToRemove getIndexes:indexes
							   maxCount:indexCount
						   inIndexRange:nil];
			
			for (NSUInteger i = 0; i < indexCount; i++) {
				NSObject* objectToDelete = [notesCopy objectAtIndex:indexes[i]];
				[[currentActivity notes] removeObject:objectToDelete];
			}
			free(indexes);
			[tableView reloadData];
		}
		[notesCopy release];
	}
}

// ----------------------------------------------------------------------------

- (IBAction)removeButtonClicked:(id)sender
{
	[self removeRows:[tableView selectedRowIndexes]];
}

// ----------------------------------------------------------------------------

- (void)displayActivityNotes:(TSKActivity*)anActivity
{
	[addButton setEnabled:YES];
	
	if (currentActivity != anActivity) {
		[currentActivity release];
		currentActivity = [anActivity retain];
		
		[tableView reloadData];
	}
}

// ----------------------------------------------------------------------------

- (void)displayMultipleNotesState
{
	[addButton setEnabled:NO];
	[removeButton setEnabled:NO];
	
	[currentActivity release];
	currentActivity = nil;
	
	[tableView reloadData];
}

// ----------------------------------------------------------------------------

- (void)displayNoNotesState
{
	[addButton setEnabled:NO];
	[removeButton setEnabled:NO];	

	[currentActivity release];
	currentActivity = nil;
	
	[tableView reloadData];
}

// ----------------------------------------------------------------------------

- (NSCell *)tableView:(NSTableView *)tableView
dataCellForTableColumn:(NSTableColumn *)tableColumn
				  row:(NSInteger)row
{
	NSCell* noteCell = nil;
	
	if (currentActivity != nil && tableColumn != nil) {
		NSUInteger noteCount = [[currentActivity notes] count];
		if (0 < noteCount && row <= noteCount) {
			NSObject* note = [[currentActivity notes] objectAtIndex:row];
			if ([note isKindOfClass:[NSString class]]) {
				noteCell = [[NSTextFieldCell alloc] init];
				[noteCell setEditable:YES];
				[(NSTextFieldCell*)noteCell setPlaceholderString:@"Double-click and type to store a new note."]; 
			}
		}
	}
	
	return noteCell;
}

// ----------------------------------------------------------------------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	NSInteger noteCount = 0;
	
	if (currentActivity != nil) {
		noteCount = [[currentActivity notes] count];
	}
	
	return noteCount;
}

// ----------------------------------------------------------------------------

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
			row:(NSInteger)row
{
	id object = nil;
	
	if (currentActivity != nil && tableColumn != nil) {
		NSUInteger noteCount = [[currentActivity notes] count];
		if (0 < noteCount && row <= noteCount) {
			object = [[currentActivity notes] objectAtIndex:row];
		}
	}
	
	return object;
}

// ----------------------------------------------------------------------------

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if (currentActivity != nil && tableColumn != nil) {
		NSUInteger noteCount = [[currentActivity notes] count];
		if (0 < noteCount && row <= noteCount) {
			[[currentActivity notes] replaceObjectAtIndex:row withObject:object];
			[[[self view] window] setDocumentEdited:YES];
		}
	}
}

// ----------------------------------------------------------------------------

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSIndexSet* selectedIndexes = [tableView selectedRowIndexes];
	
	[removeButton setEnabled:([selectedIndexes count] > 0)];
}

// ----------------------------------------------------------------------------

- (void)tableView:(NSTableView*)tableView deleteRows:(NSIndexSet*)selectedRows
{
	[self removeRows:selectedRows];
}

@end
