//
//  TSKActivityPrintData.m
//  Taskation
//
//  Created by Lyndsey on 4/8/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKActivityPrintData.h"
#import "TSKActivity.h"
#import "TSKElapsedTimeFormatter.h"

NSDictionary*				gActivityTextAttributes = nil;
CGFloat						gElapsedTimeStringWidth = 0.0;
CGFloat						gActivityTextHeight		= 0.0;
NSDateFormatter*			gDateFormatter			= nil;
TSKElapsedTimeFormatter*	gTimeFormatter			= nil;

const NSString* kElapsedTimeStringTemplate = @"0:00:00:00";

const NSString* kHeaderLocalizedKeyStrings[kHeaderColumnCount] = {  @"ActionHeaderString",
																	@"SubjectHeaderString",
																	@"StartTimeHeaderString",
																	@"EndTimeHeaderString",
																	@"ElapsedTimeHeaderString" };

// ============================================================================

NSDictionary* GetActivityTextAttributes()
{
	NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	
	[paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	
	return [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName,
															   [NSFont systemFontOfSize:11], NSFontAttributeName,
															   paragraphStyle, NSParagraphStyleAttributeName, 
															   nil];
}

// ----------------------------------------------------------------------------

CGFloat GetElapsedTimeStringWidth()
{	
	NSString* elapsedTimeString = NSLocalizedString((NSString*)kHeaderLocalizedKeyStrings[kHeaderColumnCount - 1], nil);
	
	return [elapsedTimeString sizeWithAttributes:gActivityTextAttributes].width + 2 * kHeaderCellPadding;
}

// ============================================================================

@implementation TSKActivityPrintData

+ (void)initialize
{
	if (self == [TSKActivityPrintData class]) {
		gActivityTextAttributes = GetActivityTextAttributes();
		gElapsedTimeStringWidth = GetElapsedTimeStringWidth();
		gActivityTextHeight = [@"Xj" sizeWithAttributes:gActivityTextAttributes].height;
		
		gDateFormatter = [[NSDateFormatter alloc] init];
		[gDateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[gDateFormatter setDateStyle:NSDateFormatterShortStyle];
		
		gTimeFormatter = [[TSKElapsedTimeFormatter alloc] init];
	}
}

// ----------------------------------------------------------------------------

- (id)initWithActivity:(TSKActivity*)anActivity andRect:(NSRect)aRect
{
	self = [super initWithRect:aRect];
	if (self) {
		activity = [anActivity retain];
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[activity release];
	[super dealloc];
}

// ----------------------------------------------------------------------------

+ (CGFloat)requiredHeight
{
	return gActivityTextHeight;
}

// ----------------------------------------------------------------------------

- (NSRect)cellRectForIndex:(int)theIndex
{
	NSRect cellRect;
	
	if (theIndex < 4) {
		cellRect = NSMakeRect(rect.origin.x,
							  rect.origin.y + (rect.size.height - gActivityTextHeight),
							  (rect.size.width - gElapsedTimeStringWidth)/4,
							  gActivityTextHeight);
		
		cellRect = NSOffsetRect(cellRect, theIndex * (cellRect.size.width), 0);
	}
	else {
		cellRect = NSMakeRect(rect.origin.x,
							  rect.origin.y + (rect.size.height - gActivityTextHeight),
							  gElapsedTimeStringWidth,
							  gActivityTextHeight);
		
		NSRect prevCellRect = [self cellRectForIndex:3];
		cellRect.origin.x = prevCellRect.origin.x + prevCellRect.size.width;
	}
	
	return cellRect;
}

// ----------------------------------------------------------------------------

- (void)drawActivityField:(NSString*)text inCellRect:(NSRect)cellRect
{
	NSRect textRect = NSInsetRect(cellRect, kHeaderCellPadding, kHeaderCellPadding);
	[text drawWithRect:textRect
			   options:NSStringDrawingTruncatesLastVisibleLine
			attributes:gActivityTextAttributes];
}

// ----------------------------------------------------------------------------

- (void)draw
{
	[[NSColor colorWithDeviceRed:0.00 green:0.84 blue:0.89 alpha:0.50] set];
	[NSBezierPath fillRect:rect];
	
	NSRect cellRect = [self cellRectForIndex:0];
	[self drawActivityField:[activity action] inCellRect:cellRect];
	
	cellRect = [self cellRectForIndex:1];
	[self drawActivityField:[activity subject] inCellRect:cellRect];
	
	cellRect = [self cellRectForIndex:2];
	[self drawActivityField:[gDateFormatter stringFromDate:[activity startTime]] inCellRect:cellRect];
	
	cellRect = [self cellRectForIndex:3];
	[self drawActivityField:[gDateFormatter stringFromDate:[activity endDate]] inCellRect:cellRect];
	
	cellRect = [self cellRectForIndex:4];
	[self drawActivityField:[gTimeFormatter stringForObjectValue:[activity elapsedTime]] inCellRect:cellRect];	
}

@end // TSKActivityPrintData

