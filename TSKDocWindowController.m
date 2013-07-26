//
//  TSKDocWindowController.m
//  Taskation
//
//  Created by Lyndsey on 9/27/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import "TSKDocWindowController.h"
#import "TSKActivity.h"
#import "TSKConsoleViewController.h"
#import "TSKAppController.h"
#import "TSKActivityPrintView.h"
#import "TSKDefinitions.h"
#import "TSKNotesViewController.h"
#import "TSKDocDefinitionsWindowController.h"

#define TSKSaveAndCloseNotification @"TSKSaveAndCloseNotification"

extern NSString* kActivityControlsToolbarIdentifier;
extern unsigned char markChar;

typedef enum {
	eAssociatedSaveAction_Nothing,
	eAssociatedSaveAction_CloseAfterSave,
	eAssociatedSaveAction_Rename	
} EAssociatedSaveAction;

@implementation TSKDocWindowController
@synthesize filePath;

- (id)initWithWindowNibName:(NSString*)nibName
{
	self = [super initWithWindowNibName:nibName];
	if (self) {
		isCriteriaVisible = NO;
		definitions = [[TSKDefinitions alloc] init];
	}
	
	return self;
}

// ----------------------------------------------------------------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (NSOrderedSame == [keyPath compare:@"endTime"]) {
		//TSKActivity* activity = object;
		[tableView setNeedsDisplay];
	}
}

// ----------------------------------------------------------------------------

- (void)windowDidLoad
{
	[arrayController setSelectionIndexes:[NSIndexSet indexSet]];
	
	NSSize notesViewSize = [notesView frame].size;
	[consoleViewController viewDidLoad:definitions];
	[notesViewController viewDidLoad];
	
	[consoleViewController setDelegate:self];

	[[notesViewController view] setFrameSize:notesViewSize];
	[notesView addSubview:[notesViewController view]];
	
	[self setupCriteriaView];
		
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleConsoleViewChange:) name:@"NSViewFrameDidChangeNotification" object:[consoleViewController view]];

	if (NO == [[consoleViewController view] isHidden]) {
		[consoleViewController setFirstResponder];
	}
}

// ----------------------------------------------------------------------------

- (void)openFile:(NSString*)aFilePath
{
	[filePath release];
	filePath = [aFilePath retain];
	
	NSData* data = [NSData dataWithContentsOfFile:filePath];
	NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	// Customize unarchiver here
	[activities release];
	activities = [[unarchiver decodeObjectForKey:@"activities"] retain];
	[definitions release];
	definitions = [[unarchiver decodeObjectForKey:@"activityDefinitions"] retain];
	
	// TODO: I'm not sure if this is necessary: perhaps the activity can write the 
	//	activities definition or something so that each activity refers to this same object?
	TSKActivity* activeActivity = nil;
	for (TSKActivity* activity in activities) {
		[activity setDefinitions:definitions];
		
		if ([activity isInProgress]) {
			[activity addObserver:self
						 forKeyPath:@"endTime"
							options:NSKeyValueObservingOptionNew
							context:nil];
			activeActivity = activity;
		}
	}
	
	[unarchiver finishDecoding];
	[unarchiver release];
	
	[[self window] setTitleWithRepresentedFilename:filePath];
	[[self window] setDocumentEdited:NO];
	[self showWindow:self];
	
	[consoleViewController displayCurrentActivity:activeActivity];
	[(TSKAppController*)[NSApp delegate] appendRecentFileURL:[NSURL URLWithString:filePath]];
}

// ----------------------------------------------------------------------------

- (void)openDocument
{
	NSOpenPanel* panel = [NSOpenPanel openPanel];
	[panel setRequiredFileType:TSK_DOCUMENT_FILENAME_EXTENSION];
	
	int result = [panel runModal];
	if (result == NSOKButton) {
		[self openFile:[panel filename]];
	}
}

// ----------------------------------------------------------------------------

- (void)writeFile:(NSString*)aFilePath
{
	NSMutableData* data = [NSMutableData data];
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	// Customize archiver here
	[archiver encodeObject:activities forKey:@"activities"];
	[archiver encodeObject:definitions forKey:@"activityDefinitions"];
	[archiver finishEncoding];
	
	[data writeToFile:filePath atomically:YES];
	
	[archiver release];
	[[self window] setTitleWithRepresentedFilename:filePath];
	[[self window] setDocumentEdited:NO];
}

// ----------------------------------------------------------------------------

- (void)savePanelDidEnd:(NSSavePanel *)savePanel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	NSNumber* saveActionNumber = (NSNumber*)contextInfo;
	
	if (returnCode == NSOKButton) {
		[filePath release];
		filePath = [[savePanel filename] retain];
				
		[self writeFile:filePath];
		[(TSKAppController*)[NSApp delegate] appendRecentFileURL:[NSURL URLWithString:filePath]];
		
		BOOL shouldClose = (eAssociatedSaveAction_CloseAfterSave == [saveActionNumber intValue]);
		if (shouldClose) {
			[[self window] close];
		}
	}
	[saveActionNumber release];
}

// ----------------------------------------------------------------------------

- (void)saveWithAction:(NSNumber*)saveActionNumber
{
	EAssociatedSaveAction saveAction = [saveActionNumber intValue];
	
	BOOL shouldAskForFileName = (eAssociatedSaveAction_Rename == saveAction || nil == filePath);
	if (shouldAskForFileName) {
		NSSavePanel* panel = [NSSavePanel savePanel];
		
		[panel setRequiredFileType:TSK_DOCUMENT_FILENAME_EXTENSION];
		[panel setExtensionHidden:YES];
		[panel beginSheetForDirectory:nil
								 file:nil
					   modalForWindow:[self window]
						modalDelegate:self
					   didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
						  contextInfo:saveActionNumber];
	}
	else {
		BOOL shouldClose = (eAssociatedSaveAction_CloseAfterSave == saveAction);
		
		[self writeFile:filePath];
		if (shouldClose) {
			[[self window] close];
		}
		[saveActionNumber release];
	}
}

// ----------------------------------------------------------------------------

- (void)performSave:(NSNotification*)notification
{
	[self saveWithAction:[[NSNumber alloc] initWithInt:eAssociatedSaveAction_Nothing]];
}

// ----------------------------------------------------------------------------

- (void)performSaveAs:(NSNotification*)notification
{
	[self saveWithAction:[[NSNumber alloc] initWithInt:eAssociatedSaveAction_Rename]];
}

// ----------------------------------------------------------------------------

- (void)printDocument:(NSNotification*)notification
{
	TSKActivityPrintView* activityPrintView = [[TSKActivityPrintView alloc] initWithActivityData:activities]; 

	NSRect windowRect = NSInsetRect([activityPrintView frame], -20, -20);
	NSWindow* hiddenWindow = [[NSWindow alloc] initWithContentRect:windowRect
														 styleMask:(NSTitledWindowMask|NSClosableWindowMask)
														   backing:NSBackingStoreNonretained
															 defer:NO];
	
	[[hiddenWindow contentView] addSubview:activityPrintView];
	
	NSPrintInfo* printInfo = [NSPrintInfo sharedPrintInfo];
	[printInfo setVerticalPagination:NSAutoPagination];
	
	[activityPrintView print:self];
	[hiddenWindow release];
}

// ----------------------------------------------------------------------------

- (void)alertDidEnd:(NSAlert *)alert
		 returnCode:(int)returnCode
		contextInfo:(void *)contextInfo
{	
	if (returnCode == NSAlertFirstButtonReturn) {
		[self performSelector:@selector(saveWithAction:) withObject:[[NSNumber alloc] initWithInt:eAssociatedSaveAction_CloseAfterSave] afterDelay:0];
    }
	else if (returnCode == NSAlertSecondButtonReturn) {
		[[self window] close];
	}
}

// ----------------------------------------------------------------------------

- (id)retain
{
	return [super retain];
}

// ----------------------------------------------------------------------------

-(void)windowWillClose:(NSNotification *)notification
{
}

// ----------------------------------------------------------------------------

- (BOOL)windowShouldClose:(id)window
{
	int result = YES;
	
	if (YES == [[self window] isDocumentEdited]) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:NSLocalizedString(@"SaveDocumentButton", nil)];
		[alert addButtonWithTitle:NSLocalizedString(@"DontSaveDocumentButton", nil)];
		[alert addButtonWithTitle:NSLocalizedString(@"CancelCloseDocumentButton", nil)];
		
		NSString* fileName = [[filePath pathComponents] objectAtIndex:1];
		if (fileName == nil) {
			fileName = [[self window] title];
		}
		NSString* alertText = [NSString stringWithFormat:NSLocalizedString(@"SaveDocumentChangesAlert", nil), fileName];
		
		[alert setMessageText:alertText];
		[alert setInformativeText:NSLocalizedString(@"SaveDocumentChangesAdvice", nil)];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		[alert beginSheetModalForWindow:[self window]
						  modalDelegate:self
						 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
		
		result = NO;
	}
	return result;
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[filePath release];
	[activities release];
	[searchField release];
	[definitions release];
	
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    BOOL shouldEnable = NO;
	SEL theAction = [anItem action];
	
    if (theAction == @selector(performSave:) ||
		theAction == @selector(revertDocumentToSaved:)) {

		shouldEnable = [[self window] isDocumentEdited];
	}
	else if (theAction == @selector(generateReport:) ||
			 theAction == @selector(printDocument:) ||
			 theAction == @selector(performSaveAs:)) {
		
		shouldEnable = (0 < [activities count]);
	}
	else if (theAction == @selector(performActionsAndSubjects:)) {
		shouldEnable = YES;
	}
	
	return shouldEnable;
}

// ----------------------------------------------------------------------------

- (NSMutableArray*)activities
{
	if (nil == activities) {
		activities = [[NSMutableArray alloc] init];
	}
	return activities;
}

// ----------------------------------------------------------------------------

- (void)addActivity:(TSKActivity*)anActivity
{	
	[searchField setStringValue:[NSString string]];
	[self searchFieldChanged:searchField];
	
	if (markChar == VALID_LICENSE_BYTE1 || ((markChar != VALID_LICENSE_BYTE1) && [activities count] < INVALID_MAXIMUM_ACTIVITIES)) {
		[arrayController addObject:anActivity];
		
		[[self window] setDocumentEdited:YES];
		if ([anActivity isInProgress]) {
			
			[anActivity addObserver:self
						 forKeyPath:@"endTime"
							options:NSKeyValueObservingOptionNew
							context:nil];
		}
	}
	else {
		NSBeep();
		[[NSApp delegate] performSelector:@selector(displayLicenseStatus:) withObject:nil afterDelay:0];
		[consoleViewController startStopRecording:self];
	}
}

// ----------------------------------------------------------------------------

- (void)stopCurrentActivity
{
	TSKActivity* currentActivity = [[self activities] lastObject];
	if ([currentActivity isInProgress]) {
		[currentActivity stop];
		
		[currentActivity removeObserver:self forKeyPath:@"endTime"];
		
		[[self window] setDocumentEdited:YES];
		[tableView setNeedsDisplay];
	}
}

// ----------------------------------------------------------------------------

- (void)performActionsAndSubjects:(NSNotification*)notification
{
	TSKDefinitions* editableDefinitions = [[TSKDefinitions alloc] initWithDefinitions:definitions];
	[editableDefinitions retain];
	TSKDocDefinitionsWindowController* controller = [[TSKDocDefinitionsWindowController alloc] initWithDefinitions:editableDefinitions];
	
	[[controller window] center];
	[[controller window] makeKeyAndOrderFront:self];
	
	if (NSOKButton == [NSApp runModalForWindow:[controller window]]) {
		[definitions release];
		definitions = [editableDefinitions retain];
	}
	[controller release];
	[editableDefinitions release];
}

// ----------------------------------------------------------------------------

- (void)revertDocumentToSaved:(NSNotification*)notification
{
	[self openFile:filePath];
}

@end
