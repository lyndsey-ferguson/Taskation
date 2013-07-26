//
//  TSKActivityNotesViewController.h
//  Taskation
//
//  Created by Lyndsey on 11/5/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKActivity;

@interface TSKTableView : NSTableView

@end

@interface TSKNotesViewController : NSViewController {
	IBOutlet NSButton* addButton;
	IBOutlet NSButton* removeButton;
	IBOutlet NSTableView* tableView;
	
	TSKActivity* currentActivity;
}
- (id)initWithNibName:(NSString*)nibName
			   bundle:(NSBundle *)nibBundleOrNil;

- (IBAction)addButtonClicked:(id)sender;
- (IBAction)removeButtonClicked:(id)sender;
- (void)viewDidLoad;

- (void)displayActivityNotes:(TSKActivity*)anActivity;
- (void)displayMultipleNotesState;
- (void)displayNoNotesState;

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

@end

