//
//  TSKReportWindowController.m
//  Taskation
//
//  Created by Lyndsey on 12/21/08.
//  Copyright 2008 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKReportWindowController.h"
#import "TSKReportView.h"
#import "TSKActivity.h"

typedef enum {
	eChartStyle_None,
	eChartStyle_Action,
	eChartStyle_Subject
} EChartStyle;

@implementation TSKReportWindowController

- (id)initWithActivitiesData:(NSArray*)data
{
	self = [super initWithWindowNibName:@"ReportWindow"];
	if (self) {
		activitiesData = data;
	}
	return self;
}

// ----------------------------------------------------------------------------

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    BOOL shouldEnable = NO;
	SEL theAction = [anItem action];
	
    if (theAction == @selector(chartStylePopupButtonChanged:) ||
		theAction == @selector(chartScalePopupButtonChanged:)) {
		shouldEnable = YES;
	}
	else if (theAction == @selector(performSave:) ||
		theAction == @selector(performSaveAs:) ||
		theAction == @selector(revertDocumentToSaved:)) {
		
		shouldEnable = [[self window] isDocumentEdited];
	}
	else if (theAction == @selector(performGenerateReport:)) {
		shouldEnable = NO;
	}
	
	return shouldEnable;
}

// ----------------------------------------------------------------------------

- (NSDictionary*)reportDataUsingCategorization:(EChartStyle)chartStyle
{
	NSMutableDictionary* reportData = [NSMutableDictionary dictionaryWithCapacity:[activitiesData count]];
	for (TSKActivity* activity in activitiesData) {
		NSString* componentString = nil;
		NSNumber* componentTime = nil;
		
		switch(chartStyle) {
			case eChartStyle_None: {
				componentString = [NSString stringWithFormat:@"%@: %@", [activity action], [activity subject]];
				break;
			}
			case eChartStyle_Action: {
				componentString = [NSString stringWithFormat:@"%@", [activity action]];
				break;
			}
			case eChartStyle_Subject: {
				componentString = [NSString stringWithFormat:@"%@", [activity subject]];
				break;
			}
			default: {
				NSException* e = [NSException exceptionWithName:NSInternalInconsistencyException
														 reason:@"Unexpected report chartStyle used."
													   userInfo:nil];
				[e raise];
			}
		}		
		componentTime = [reportData objectForKey:componentString];
		if (nil != componentTime) {
			componentTime = [NSNumber numberWithInt:([[activity elapsedTime] intValue] + [componentTime intValue])];
		}
		else {
			componentTime = [NSNumber numberWithInt:[[activity elapsedTime] intValue]];
		}
		[reportData setObject:componentTime forKey:componentString];
	}
	return reportData;
}

// ----------------------------------------------------------------------------

- (void)updateReportPageSize:(CGFloat)aScaleFactor
{
	NSPrintInfo* printInfo = [NSPrintInfo sharedPrintInfo];
	NSRect pageRect = NSMakeRect(0, 0, 1, 1);
	
	pageRect.size = [printInfo paperSize];	
	pageRect.size.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
	pageRect.size.width -= ([printInfo leftMargin] + [printInfo rightMargin]);
		
	pageRect.size.height *= aScaleFactor;
	pageRect.size.width *= aScaleFactor;
	
	[reportView setFrameSize:pageRect.size];
	[[reportView superview] setFrameSize:pageRect.size];
	[scrollView resizeSubviewsWithOldSize:[scrollView contentSize]];
	[scrollView setNeedsDisplay:YES];
#if 1
	NSSize scrollViewSize = [[[reportView superview] superview] frame].size;
	NSSize frameSize = [reportView frame].size ;
	NSPoint frameOrigin;
	
	frameOrigin.x = frameOrigin.y = 0.0;
	
	if ( scrollViewSize.height >= frameSize.height )
		frameOrigin.y=((long) (scrollViewSize.height - frameSize.height));
	
	[[reportView superview] setFrameOrigin:frameOrigin];
#endif
}

// ----------------------------------------------------------------------------

- (double)currentlySelectedScale
{
	return ([[[chartScaleButton itemAtIndex:0] title] doubleValue] / 100.0);
}

// ----------------------------------------------------------------------------

- (EChartStyle)currentlySelectedChartStyle
{
	EChartStyle chartStyle = eChartStyle_None;
	if (1 == [chartStyleButton indexOfSelectedItem]) {
		chartStyle = eChartStyle_Action;
	}
	else if (2 == [chartStyleButton indexOfSelectedItem]) {
		chartStyle = eChartStyle_Subject;
	}
	return chartStyle;
}

// ----------------------------------------------------------------------------

- (void)pageSizeChanged
{
	[self updateReportPageSize:[self currentlySelectedScale]];
	
	EChartStyle chartStyle = [self currentlySelectedChartStyle];
	[reportView setReportData:[self reportDataUsingCategorization:chartStyle]];
	[[self window] setDocumentEdited:YES];	
}

// ----------------------------------------------------------------------------

- (void)windowDidLoad
{		
	NSSize chartStyleButtonSize = [chartStyleButton frame].size;
	NSSize chartScaleButtonSize = [chartScaleButton frame].size;
	
	NSRect horizontalScrollerRect = [horizontalScroller frame];
	horizontalScrollerRect.size.width -= (chartStyleButtonSize.width + chartScaleButtonSize.width);
	horizontalScrollerRect.origin.x += (chartStyleButtonSize.width + chartScaleButtonSize.width);
	[horizontalScroller setFrame:horizontalScrollerRect];
	
	[self updateReportPageSize:1.0];
	[[self window] setDocumentEdited:YES];
	[reportView setReportData:[self reportDataUsingCategorization:eChartStyle_None]];
}

// ----------------------------------------------------------------------------

- (IBAction)chartStylePopupButtonChanged:(id)sender
{
	NSLog(@"combinePopupButtonChanged: %d", [(NSPopUpButton*)sender intValue]);
	EChartStyle chartStyle = [self currentlySelectedChartStyle];
	
	[reportView setReportData:[self reportDataUsingCategorization:chartStyle]];
	[[self window] setDocumentEdited:YES];	
}

// ----------------------------------------------------------------------------
- (IBAction)chartScalePopupButtonChanged:(id)sender
{	
	NSPopUpButton* scalePopup = sender;
	
	NSInteger selectedIndex = [scalePopup indexOfSelectedItem];
	
	BOOL hasSelectedSeparator =  (1 == selectedIndex);
	BOOL hasSelectedCustom = ([scalePopup numberOfItems] - 1 == selectedIndex);
	BOOL hasSelectedCurrent = (0 == selectedIndex);
	
	CGFloat newScaleFactor = 1.0;
	CGFloat curScaleFactor = [self currentlySelectedScale];
	
	[[customScaleField currentEditor] setString:[[scalePopup itemAtIndex:0] title]];
	
	NSString* newScaleFactorString = nil;
	if (!(hasSelectedCustom || hasSelectedSeparator || hasSelectedCurrent)) {
		newScaleFactorString = [[scalePopup selectedItem] title];
		CGFloat chosenValue = [newScaleFactorString doubleValue];
		newScaleFactor = (chosenValue / 100.0);
	}
	else if (hasSelectedCustom) {
		[customScaleWindow center];
		[customScaleWindow makeKeyAndOrderFront:self];
		[NSApp runModalForWindow:customScaleWindow];
		[customScaleWindow orderOut:self];
		
		newScaleFactorString = [customScaleField stringValue];
		CGFloat chosenValue = [newScaleFactorString doubleValue];
		newScaleFactor = (chosenValue / 100.0);
	}
	[scalePopup selectItemAtIndex:0];
	
	if (curScaleFactor != newScaleFactor) {
		[[scalePopup itemAtIndex:0] setTitle:newScaleFactorString];
		[self updateReportPageSize:newScaleFactor];
		[reportView setReportScale:newScaleFactor];
	}
}

// ----------------------------------------------------------------------------

- (IBAction)customScaleOKButtonClicked:(id)sender
{
	CGFloat chosenValue = [customScaleField doubleValue];

	if (0.0 == chosenValue) {
		[[customScaleField currentEditor] setString:@"100"];
		[[customScaleField currentEditor] selectAll:self];
		NSBeep();
	}
	else {
		[NSApp stopModalWithCode:NSOKButton];
	}
}

// ----------------------------------------------------------------------------

- (void)writeFile:(NSString*)aFilePath
{
	NSRect viewRect = [reportView bounds];
	NSData* pdfData = [reportView dataWithPDFInsideRect:viewRect];
	
	[pdfData writeToFile:aFilePath atomically:YES];
	
	[[self window] setTitleWithRepresentedFilename:aFilePath];
	[[self window] setDocumentEdited:NO];
}

// ----------------------------------------------------------------------------

- (void)savePanelDidEnd:(NSSavePanel *)savePanel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton) {
		filePath = [[savePanel filename] retain];
		
		[self writeFile:filePath];
	}
}

// ----------------------------------------------------------------------------

- (void)performSave:(NSNotification*)notification
{
	if (nil == filePath) {
		NSSavePanel* panel = [NSSavePanel savePanel];
		
		[panel setRequiredFileType:@"pdf"];
		
		[panel beginSheetForDirectory:nil
								 file:nil
					   modalForWindow:[self window]
						modalDelegate:self
					   didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
						  contextInfo:NULL];	
	}
	else {
		[self writeFile:filePath];
	}
}

// ----------------------------------------------------------------------------

- (void)performSaveAs:(NSNotification*)notification
{
	NSLog(@"- [TSKReportWindowController performSaveAs:]");
}

// ----------------------------------------------------------------------------

- (void)printDocument:(NSNotification*)notification
{
	CGFloat curScaleFactor = [self currentlySelectedScale];
	[self updateReportPageSize:1.0];
	[reportView setReportScale:1.0];

	NSPrintInfo* printInfo = [NSPrintInfo sharedPrintInfo];
	
	NSPrintingPaginationMode savedHorizontalMode = [printInfo horizontalPagination];
	NSPrintingPaginationMode savedVerticalMode = [printInfo verticalPagination];
	
	[printInfo setHorizontalPagination:NSFitPagination];
	[printInfo setVerticalPagination:NSFitPagination];
	
	[reportView print:self];
	
	[printInfo setHorizontalPagination:savedHorizontalMode];
	[printInfo setVerticalPagination:savedVerticalMode];
	
	[self updateReportPageSize:curScaleFactor];
	[reportView setReportScale:curScaleFactor];
}

// ----------------------------------------------------------------------------

- (void)revertDocumentToSaved:(NSNotification*)notification
{
	
}

@end
