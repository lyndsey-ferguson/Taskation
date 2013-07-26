//
//  TSKActivityControlsViewController.m
//  Taskation
//
//  Created by Lyndsey on 10/16/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import "TSKConsoleViewController.h"
#import "TSKActionComboBoxDepot.h"
#import "TSKSubjectComboBoxDepot.h"
#import "TSKCommonConstants.h"
#import "TSKActivity.h"
#import "TSKDefinitions.h"

@implementation TSKConsoleViewController

@synthesize shouldEnableRecordButton;
@synthesize delegate;

- (id)initWithNibName:(NSString*)nibName
			   bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibName bundle:nibBundleOrNil];
		
	return self;
}

// ----------------------------------------------------------------------------

- (void)viewDidLoad:(TSKDefinitions*)theDefinitions
{	
	activityDefinitions = [theDefinitions retain];
	
	TSKActionComboBoxDepot* actionsDepot = [[TSKActionComboBoxDepot alloc] initWithDefinitions:activityDefinitions];
	TSKSubjectComboBoxDepot* subjectsDepot = [[TSKSubjectComboBoxDepot alloc] initWithDefinitions:activityDefinitions andActionComboBox:actionsComboBox];
	
	[actionsComboBox setUsesDataSource:YES];
	[subjectsComboBox setUsesDataSource:YES];
	
	[actionsComboBox setDataSource:actionsDepot];
	[subjectsComboBox setDataSource:subjectsDepot];
	
	[actionsComboBox setCompletes:YES];
	[subjectsComboBox setCompletes:YES];
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[activityDefinitions release];
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (void)setFirstResponder
{
	[[[self view] window] makeFirstResponder:actionsComboBox];
}

// ----------------------------------------------------------------------------

- (NSToolbarSizeMode)sizeMode
{
	NSCell* cell = [actionsComboBox cell];
	NSControlSize controlSize = [cell controlSize];
	
	NSToolbarSizeMode sizeMode = NSToolbarSizeModeRegular;
	switch (controlSize) {
		case NSSmallControlSize:
			sizeMode = NSToolbarSizeModeRegular;
			break;
		case NSMiniControlSize:
			sizeMode = NSToolbarSizeModeSmall;
			break;
		default:
			NSLog(@"Unknown Control Size.");
			break;
	}
	return sizeMode;
}

- (void)setSizeMode:(NSToolbarSizeMode)sizeMode
{
	if (sizeMode != [self sizeMode]) {
		if (NSToolbarSizeModeRegular == sizeMode) {
			[[actionsComboBox cell] setControlSize:NSSmallControlSize];
			[[subjectsComboBox cell] setControlSize:NSSmallControlSize];
			
			NSRect bounds = [startStopButton frame];
			bounds = NSInsetRect(bounds, -4, -4);
			[startStopButton setFrame:bounds];
			[startStopButton setNeedsDisplay];
		}
		else {
			[[actionsComboBox cell] setControlSize:NSMiniControlSize];
			[[subjectsComboBox cell] setControlSize:NSMiniControlSize];

			NSRect bounds = [startStopButton frame];
			bounds = NSInsetRect(bounds, 4, 4);
			[startStopButton setFrame:bounds];
			[startStopButton setNeedsDisplay];
		}
	}
}

// ----------------------------------------------------------------------------

- (BOOL)shouldBeginActivityWithAction:(NSString**)actionID
							  subject:(NSString**)subjectID
{
	*actionID = [activityDefinitions actionIDForAction:[actionsComboBox stringValue]];
	*subjectID = [activityDefinitions subjectIDForSubject:[subjectsComboBox stringValue]];
	
	BOOL isKnownAction = (0 < [*actionID length]);
	BOOL isKnownSubject = (0 < [*subjectID length]);
	
	BOOL shouldBeginActivity = (isKnownAction && isKnownSubject);
	
	if (!shouldBeginActivity) {
		NSString* title = nil;
		NSString* message = nil;
		NSString* defaultButton = nil;
		
		if (!isKnownAction && !isKnownSubject) {
			message = [NSString stringWithFormat:NSLocalizedString(@"UnknownActionSubjectDialogMessage", nil), [actionsComboBox stringValue], [subjectsComboBox stringValue]];
			title = NSLocalizedString(@"UnknownActionSubjectDialogTitle", nil);
			defaultButton = NSLocalizedString(@"UnknownActionSubjectDialogDefaultButton", nil);
		}
		else if (!isKnownSubject) {
			message = [NSString stringWithFormat:NSLocalizedString(@"UnknownSubjectDialogMessage", nil), [subjectsComboBox stringValue]];
			title = NSLocalizedString(@"UnknownSubjectDialogTitle", nil);
			defaultButton = NSLocalizedString(@"UnknownSubjectDialogDefaultButton", nil);
		}
		else {
			NSLog(@"Unexpected situation, an unknown action exists, with a known subject: this should never happen as there should not be any subjects associated with an unknown action.");
		}
	
		BOOL createActionAndOrSubject = (NSAlertDefaultReturn == NSRunAlertPanel(title, message, defaultButton, NSLocalizedString(@"UnknownActionSubjectDialogCancelButton", nil), nil));
		if (createActionAndOrSubject) {
			if (!isKnownSubject) {
				*subjectID = [activityDefinitions addSubject:[subjectsComboBox stringValue]];
			}
			if (!isKnownAction) {
				*actionID = [activityDefinitions addAction:[actionsComboBox stringValue]];
			}
			
			shouldBeginActivity = [activityDefinitions associateSubject:*subjectID withAction:*actionID];;
		}
		
	}
	
	return shouldBeginActivity;
}

// ----------------------------------------------------------------------------

- (void)displayCurrentActivity:(TSKActivity*)anActivity
{
	if (anActivity != nil) {
		isRecording = YES;
		[startStopButton setState:NSOnState];
		[startStopButton setEnabled:YES];
		[actionsComboBox setStringValue:[anActivity action]];
		[subjectsComboBox setStringValue:[anActivity subject]];
		[actionsComboBox setEnabled:NO];
		[subjectsComboBox setEnabled:NO];
	}
}
// ----------------------------------------------------------------------------

- (IBAction)startStopRecording:(id)sender
{
	BOOL requestedToRecord = !isRecording;
	
	if (requestedToRecord) {
		NSString* actionID = nil;
		NSString* subjectID = nil;
		
		if ([self shouldBeginActivityWithAction:&actionID subject:&subjectID]) {
			isRecording = YES;

			[actionsComboBox setEnabled:NO];
			[subjectsComboBox setEnabled:NO];
		
			TSKActivity* newActivity = [[TSKActivity alloc] initWithActionID:actionID subjectID:subjectID andDefinitions:activityDefinitions];
			[delegate addActivity:newActivity];
		}
		else {
			[startStopButton setState:NSOffState];
			isRecording = NO;
		}
	}
	else {
		[delegate stopCurrentActivity];
		[actionsComboBox setEnabled:YES];
		[subjectsComboBox setEnabled:YES];
		[startStopButton setState:NSOffState];
		isRecording = NO;
	}
}

// ----------------------------------------------------------------------------

- (IBAction)actionComboBoxChanged:(id)sender
{
	[subjectsComboBox setStringValue:@""];

	if ([[actionsComboBox stringValue] length] > 0) {
		[subjectsComboBox setEnabled:YES];
	}
	else {
		[subjectsComboBox setEnabled:NO];
	}
}

// ----------------------------------------------------------------------------

- (IBAction)subjectComboBoxChanged:(id)sender
{
	if ([[subjectsComboBox stringValue] length] > 0) {
		[startStopButton setEnabled:YES];
	}
	else {
		[startStopButton setEnabled:NO];
	}
}

// ----------------------------------------------------------------------------

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSComboBox* changedComboBox = [aNotification object];
	if (changedComboBox == actionsComboBox) {
		[self actionComboBoxChanged:self];
	}
	else if (changedComboBox == subjectsComboBox) {
		[self subjectComboBoxChanged:self];
	}
	else {
		NSLog(@"Unexpected NSComboBox posting a controlTextDidChange notification.");
	}
}

@end
