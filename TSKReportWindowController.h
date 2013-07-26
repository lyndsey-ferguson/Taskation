//
//  TSKReportWindowController.h
//  Taskation
//
//  Created by Lyndsey on 12/21/08.
//  Copyright 2008 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKReportView;

@interface TSKReportWindowController : NSWindowController {
	IBOutlet NSPopUpButton* chartStyleButton;
	IBOutlet NSPopUpButton* chartScaleButton;
	IBOutlet NSScroller* horizontalScroller;
	IBOutlet NSTextField* customScaleField;
	IBOutlet NSWindow* customScaleWindow;
	IBOutlet NSScrollView* scrollView;
	
	IBOutlet TSKReportView* reportView;
	NSString* filePath;
	NSArray* activitiesData;
}

- (id)initWithActivitiesData:(NSArray*)data;
- (IBAction)chartStylePopupButtonChanged:(id)sender;
- (IBAction)chartScalePopupButtonChanged:(id)sender;
- (IBAction)customScaleOKButtonClicked:(id)sender;

- (void)performSave:(NSNotification*)notification;
- (void)performSaveAs:(NSNotification*)notification;
- (void)revertDocumentToSaved:(NSNotification*)notification;
- (void)printDocument:(NSNotification*)notification;

- (void)pageSizeChanged;
@end
