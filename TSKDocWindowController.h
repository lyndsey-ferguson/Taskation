//
//  TSKDocWindowController.h
//  Taskation
//
//  Created by Lyndsey on 9/27/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKTasksDepot;
@class TSKConsoleViewController;
@class TSKNotesViewController;
@class TSKCriteriaViewController;
@class TSKActivity;
@class TSKDefinitions;

@interface TSKDocWindowController : NSWindowController {

/* GUI Elements */
	/* Main Document */
	IBOutlet NSTableView* tableView;
	IBOutlet NSView* notesView;
	IBOutlet NSView* splitView;

	/* The Toolbar */
	IBOutlet NSToolbar* toolbar;
	IBOutlet NSView* predicateEditorView;
	IBOutlet NSPredicateEditor* predicateEditor;
	NSSearchField* searchField;
	
	/* Sub-controllers */
	IBOutlet TSKConsoleViewController*	consoleViewController;
	IBOutlet TSKNotesViewController* notesViewController;

	/* Array Controller */
	IBOutlet NSArrayController* arrayController;
	
	/* Actions and Subjects Window */
	IBOutlet NSView* definitionsSuperview;
	
	/* Internal State/Data values */
	NSMutableArray*				activities;
	IBOutlet TSKDefinitions*	definitions;
	NSString*					filePath;
	BOOL						isCriteriaVisible;
}
@property (readonly) NSString* filePath;

- (NSMutableArray*)activities;
- (id)retain;
- (void)windowDidLoad;
- (void)performSave:(NSNotification*)notification;
- (void)performSaveAs:(NSNotification*)notification;
- (void)printDocument:(NSNotification*)notification;
- (void)openDocument;
- (void)openFile:(NSString*)aFilePath;
- (void)addActivity:(TSKActivity*)anActivity;
- (void)stopCurrentActivity;

- (void)performActionsAndSubjects:(NSNotification*)notification;

@end

@interface TSKDocWindowController (ActivitiesTable)

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

@end

@interface TSKDocWindowController (DocumentToolbar)

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
- (void)toolbarWillAddItem:(NSNotification *)notification;

@end

@interface TSKDocWindowController (Criteria)

- (void)setupCriteriaView;
- (IBAction)ruleEditorDidChange:(id)sender;
- (void)searchFieldChanged:(id)sender;

@end

@interface TSKDocWindowController (Reports)

- (void)generateReport:(NSNotification*)notification;
@end
