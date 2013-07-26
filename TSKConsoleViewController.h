//
//  TSKActivityControlsViewController.h
//  Taskation
//
//  Created by Lyndsey on 10/16/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKDefinitions;
@class TSKActivity;

@interface TSKConsoleViewController : NSViewController {
	BOOL shouldEnableRecordButton;
	BOOL isRecording;
	
	IBOutlet NSComboBox* actionsComboBox;
	IBOutlet NSComboBox* subjectsComboBox;
	IBOutlet NSSearchField* searchField;
	
	IBOutlet NSButton* startStopButton;
	IBOutlet id delegate;
	
	TSKDefinitions* activityDefinitions;
}

@property (readonly) BOOL shouldEnableRecordButton;
@property (retain) id delegate;

- (IBAction)startStopRecording:(id)sender;
- (void)displayCurrentActivity:(TSKActivity*)anActivity;
- (IBAction)actionComboBoxChanged:(id)sender;
- (IBAction)subjectComboBoxChanged:(id)sender;

- (void)viewDidLoad:(TSKDefinitions*)theDefinitions;
- (void)setFirstResponder;

- (void)controlTextDidChange:(NSNotification *)aNotification;

- (NSToolbarSizeMode)sizeMode;
- (void)setSizeMode:(NSToolbarSizeMode)sizeMode;

@end

@class TSKActivity;

@interface NSObject (TSKActivityControlsViewDelegate)
- (void)addActivity:(TSKActivity*)anActivity;
- (void)stopCurrentActivity;
@end
