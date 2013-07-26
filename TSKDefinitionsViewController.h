//
//  TSKActivityDefsViewController.h
//  Taskation
//
//  Created by Lyndsey on 3/31/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKDefinitions;

@interface TSKDefinitionsViewController : NSViewController {
	IBOutlet NSTableView* actionsTableView;
	IBOutlet NSTableView* subjectsTableView;
	IBOutlet NSButton* addActionButton;
	IBOutlet NSButton* removeActionButton;
	IBOutlet NSButton* addSubjectButton;
	IBOutlet NSButton* removeSubjectButton;

	IBOutlet TSKDefinitions* definitions;
}
@property (readonly) TSKDefinitions* definitions;

- (id)initWithDefinitions:(TSKDefinitions*)theDefinitions;

- (IBAction)addActionButtonClicked:(id)sender;
- (IBAction)removeActionButtonClicked:(id)sender;
- (IBAction)addSubjectButtonClicked:(id)sender;
- (IBAction)removeSubjectButtonClicked:(id)sender;

- (void)setActionSubjectInitialState;
- (void)updateButtonsEnableState;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
			row:(NSInteger)row;

- (void)tableView:(NSTableView *)tableView
   setObjectValue:(id)object
   forTableColumn:(NSTableColumn *)tableColumn
			  row:(NSInteger)row;

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

- (BOOL)tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
	 toPasteboard:(NSPasteboard *)pboard;

- (NSDragOperation)tableView:(NSTableView*)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op;

- (BOOL)tableView:(NSTableView *)aTableView
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)operation;
@end
