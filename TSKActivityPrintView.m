//
//  TSKActivityPrintView.m
//  Taskation
//
//  Created by Lyndsey on 3/25/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKActivityPrintView.h"
#import "TSKActivity.h"
#import "TSKElapsedTimeFormatter.h"
#import "TSKActivityPrintData.h"
#import "TSKNotePrintData.h"

// ----------------------------------------------------------------------------

void AdjustDocHeightAndTextBlock(NSRect* block, CGFloat* docHeight, CGFloat pageHeight, CGFloat bottomMargin)
{
	if (block && docHeight) {
		if ((*block).origin.y < bottomMargin) {
			*docHeight += (*block).size.height + (*block).origin.y;
			(*block).origin.y = pageHeight;
		}
	}
}

// ----------------------------------------------------------------------------

BOOL AdjustTextBlockOntoAppropriatePage(NSRect* textBlock, NSRect* currentPageRect, CGFloat* documentHeight)
{
	BOOL hasAdjusted = NO;
	if (textBlock && currentPageRect && documentHeight) {
		NSRect intersectionRect = NSIntersectionRect(*textBlock, *currentPageRect);
		if (!NSEqualRects(*textBlock, intersectionRect)) {
			*documentHeight += intersectionRect.size.height;
			(*currentPageRect).origin.y -= (*currentPageRect).size.height;
			(*textBlock).origin.y -= intersectionRect.size.height;
			
			hasAdjusted = YES;
		}
	}
	return hasAdjusted;
}

// ----------------------------------------------------------------------------

void CreateDrawingData(NSArray* activityData, NSMutableArray** data, NSRect* documentRect)
{
	if (data && documentRect) {
		*data = [[NSMutableArray alloc] init];
						
		NSPrintInfo* printInfo = [NSPrintInfo sharedPrintInfo];
		NSRect pageRect = NSMakeRect(0, 0, 1, 1);
		
		pageRect.size = [printInfo paperSize];	
		pageRect.size.height -= ([printInfo topMargin] + [printInfo bottomMargin]);
		pageRect.size.width -= ([printInfo leftMargin] + [printInfo rightMargin]);
		
		*documentRect = NSMakeRect(0, 0, pageRect.size.width, 0);
		
		NSRect noteRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
		NSRect fieldsRect = NSMakeRect(0.0, pageRect.size.height - [TSKActivityPrintData requiredHeight], pageRect.size.width, [TSKActivityPrintData requiredHeight]);
		
		NSRect intersectionRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
		
		NSRect currentPageRect = pageRect;
		
		for (TSKActivity* activity in activityData) {
			TSKActivityPrintData* actPrintData = [[TSKActivityPrintData alloc] initWithActivity:activity andRect:fieldsRect];
			[*data addObject:actPrintData];

			(*documentRect).size.height += fieldsRect.size.height + kHeaderCellPadding;

			noteRect = NSMakeRect(kNoteRowIndent, 
										 0.0,
										 pageRect.size.width - kNoteRowIndent,
										 0.0);
			
 			if ([[activity notes] count] == 0) {
				fieldsRect.origin.y = fieldsRect.origin.y - (fieldsRect.size.height + kHeaderCellPadding);
			}
			else {
				for (NSString* note in [activity notes]) {
					noteRect.size.height = [TSKNotePrintData heightOfWrappedText:note forWidth:noteRect.size.width] + kHeaderCellPadding;
					noteRect.origin.y = (fieldsRect.origin.y - (noteRect.size.height + kHeaderCellPadding));
					
					if (!AdjustTextBlockOntoAppropriatePage(&noteRect, &currentPageRect, &(*documentRect).size.height)) {
						(*documentRect).size.height += noteRect.size.height + kHeaderCellPadding;
					}
					fieldsRect.origin.y = noteRect.origin.y;
					
					TSKNotePrintData* notePrintData = [[TSKNotePrintData alloc] initWithNote:note andRect:noteRect];
					[*data addObject:notePrintData];					
				}
				fieldsRect.origin.y = noteRect.origin.y - ([TSKActivityPrintData requiredHeight] + kHeaderCellPadding);
			}	
			AdjustTextBlockOntoAppropriatePage(&fieldsRect, &currentPageRect, &(*documentRect).size.height);
			intersectionRect = NSIntersectionRect(fieldsRect, currentPageRect);
		}
		
		if ((*documentRect).size.height > pageRect.size.height) {
			double multiplier = ceil((*documentRect).size.height / pageRect.size.height);
			(*documentRect).size.height = (pageRect.size.height * multiplier);
		}
		else {
			(*documentRect).size.height = pageRect.size.height;
		}
		CGFloat deltaY = ((*documentRect).size.height - pageRect.size.height);
		if (deltaY > 0) {
			NSRect printDataRect = { 0.0, 0.0, 0.0, 0.0 };
			for (TSKPrintData* printData in *data) {
				printDataRect = [printData rect];
				printDataRect.origin.y += deltaY;
				[printData setRect:printDataRect];
			}
		}
	}			
}
// ============================================================================

@implementation TSKActivityPrintView

- (id)initWithActivityData:(NSArray*)activityData
{
	NSRect theRect;
	CreateDrawingData(activityData, &printDataBlocks, &theRect);
	
	self = [super initWithFrame:theRect];
	if (self) {
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[printDataBlocks release];	
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (void)drawRect:(NSRect)rect
{
    if (NO == [[NSGraphicsContext currentContext] isDrawingToScreen]) {
		// Draw the image in the current context.
		for (TSKPrintData* printData in printDataBlocks) {
			NSRect printDataRect = [printData rect];
			
			BOOL canDraw = NSContainsRect(rect, printDataRect);
			
			if (canDraw) {
				[printData draw];
			}
		}
	}
}

@end
