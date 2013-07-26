//
//  TSKDocCriteriaController.m
//  Taskation
//
//  Created by Lyndsey on 12/13/08.
//  Copyright 2008 Lyndsey D. Ferguson. All rights reserved.
//
#import "TSKDocWindowController.h"
#import "TSKElapsedTimeFormatter.h"

const NSUInteger TSKCriteriaRowHeight = 25;

unsigned char modder = INVALID_LICENSE_BYTE2;

@implementation TSKDocWindowController (Criteria)

- (void)setupCriteriaView
{
	[predicateEditorView removeFromSuperview];
	
	NSRect contentBounds = [[[self window] contentView] frame];
	[predicateEditorView setFrame:NSMakeRect(0, contentBounds.size.height, contentBounds.size.width, 0)];
	[[[self window] contentView] addSubview:predicateEditorView];
	
	NSPredicateEditorRowTemplate* rowTemplate = [[predicateEditor rowTemplates] objectAtIndex:2];
	NSDatePicker* datePicker = [[rowTemplate templateViews] objectAtIndex:2];
	[datePicker setDatePickerElements:(NSHourMinuteSecondDatePickerElementFlag|NSYearMonthDayDatePickerElementFlag)];
	
	NSRect frame;
	frame = [datePicker frame];
	frame.size.width += 50;
	[datePicker setFrame:frame];
	
	rowTemplate = [[predicateEditor rowTemplates] objectAtIndex:3];
	NSTextField* textField = [[rowTemplate templateViews] objectAtIndex:2];
	[[textField cell] setFormatter:[[TSKElapsedTimeFormatter alloc] init]];
	
	frame = [textField frame];
	frame.size.width += 80;
	[textField setFrame:frame];
}

// ----------------------------------------------------------------------------

- (NSUInteger)criteriaViewHeight
{
	NSUInteger numberOfRows = [predicateEditor numberOfRows];
	
	return (TSKCriteriaRowHeight * numberOfRows) + 2;
}

// ----------------------------------------------------------------------------

- (void)adjustCriteriaView
{
	NSRect contentRect = [[[self window] contentView] frame];
	NSRect splitViewRect = [splitView frame];
	
	NSRect editorRect;
	editorRect.size.height = [self criteriaViewHeight];
	editorRect.size.width = splitViewRect.size.width;
	editorRect.origin.x = splitViewRect.origin.x;
	editorRect.origin.y = (contentRect.size.height - editorRect.size.height);
	
	[predicateEditorView setFrame:editorRect];	
}

// ----------------------------------------------------------------------------

- (void)showCriteria:(NSString*)actionString
{
	NSPredicate* actionPredicate = [NSPredicate predicateWithFormat:@"action contains[cd] %@", actionString];
	
	NSPredicate* compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:actionPredicate, nil]]; 
	
	[predicateEditor setObjectValue:compoundPredicate];
	[arrayController setFilterPredicate:[predicateEditor predicate]];
	
	[predicateEditorView setHidden:NO];
}

// ----------------------------------------------------------------------------

- (void)hideCriteria
{
	[arrayController setFilterPredicate:nil];
	[predicateEditorView setHidden:YES];
}

// ----------------------------------------------------------------------------

- (void)adjustWindowToCriteriaView:(BOOL)isNowVisible
{
	NSRect criteriaRect;
	
	if ([predicateEditorView isHidden]) {
		NSRect contentRect = [[[self window] contentView] frame];
		criteriaRect.origin.y = (contentRect.size.height);
	}
	else {
		criteriaRect = [predicateEditorView frame];
	} 
	NSRect splitViewRect = [splitView frame];
	
	CGFloat splitViewTopCoord = (splitViewRect.origin.y + splitViewRect.size.height);
	CGFloat criteriaBottomCoord = (criteriaRect.origin.y);
	
	CGFloat heightDelta = 7 - (criteriaBottomCoord - splitViewTopCoord);
	
	if (heightDelta != 0) {
		splitViewRect.size.height -= heightDelta;
		[splitView setFrame:splitViewRect];
		
		NSRect windowRect = [[self window] frame];
		
		windowRect.origin.y -= heightDelta;
		windowRect.size.height += heightDelta;
		
		[[self window] setFrame:windowRect display:YES animate:YES];
	}
}

// ----------------------------------------------------------------------------

- (void)searchFieldChanged:(id)sender
{	
	BOOL needToShowCriteriaView = ([[sender stringValue] length] > 0 && !isCriteriaVisible);
	BOOL needToHideCriteriaView = ([[sender stringValue] length] == 0 && isCriteriaVisible);
	
	if  (needToShowCriteriaView) {
		[self showCriteria:[sender stringValue]];
		isCriteriaVisible = YES;
	}
	else if (needToHideCriteriaView) {
		[self hideCriteria];
		isCriteriaVisible = NO;
	}
	
	if (needToHideCriteriaView || needToShowCriteriaView) {
		[self adjustCriteriaView];
		[self adjustWindowToCriteriaView:isCriteriaVisible];
	}
}

// ----------------------------------------------------------------------------

- (IBAction)ruleEditorDidChange:(id)sender
{
	[arrayController setFilterPredicate:[predicateEditor predicate]];
	[self adjustCriteriaView];
	[self adjustWindowToCriteriaView:isCriteriaVisible];
}

@end
