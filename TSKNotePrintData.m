//
//  TSKNotePrintData.m
//  Taskation
//
//  Created by Lyndsey on 4/8/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKNotePrintData.h"

NSDictionary* gNoteTextAttributes = nil;

// ============================================================================

NSDictionary* GetNoteTextAttributes()
{
	NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	[paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
	
	return [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSColor whiteColor], NSBackgroundColorAttributeName,
			 [NSColor blackColor], NSForegroundColorAttributeName,
			 [NSFont systemFontOfSize:10], NSFontAttributeName,
			 //			 paragraphStyle, NSParagraphStyleAttributeName,
			 nil];
}

// ----------------------------------------------------------------------------

CGFloat GetStringHeight(NSString* string, NSFont* font, CGFloat widthToDrawInto)
{
	NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString:string] autorelease];
	NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize: NSMakeSize(widthToDrawInto, FLT_MAX)] autorelease];
	NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init] autorelease];
	
	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];
	
	[textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [textStorage length])];
	[textContainer setLineFragmentPadding:0.0];
	
	(void) [layoutManager glyphRangeForTextContainer:textContainer];
	return [layoutManager usedRectForTextContainer:textContainer].size.height;
}

// ----------------------------------------------------------------------------


@implementation TSKNotePrintData

+ (CGFloat)heightOfWrappedText:(NSString*)theText forWidth:(CGFloat)theWidth
{
	return GetStringHeight(theText, [gNoteTextAttributes objectForKey:NSFontAttributeName], theWidth);
}

// ----------------------------------------------------------------------------

+ (void)initialize
{
	if (self == [TSKNotePrintData class]) {
		gNoteTextAttributes = GetNoteTextAttributes();
	}
}

// ----------------------------------------------------------------------------

- (id)initWithNote:(NSString*)noteString andRect:(NSRect)aRect
{
	self = [super initWithRect:aRect];
	if (self) {
		note = [noteString retain];
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[note release];
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (void)draw
{
	[note drawInRect:rect withAttributes:gNoteTextAttributes];
}
@end
