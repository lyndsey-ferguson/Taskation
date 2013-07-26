//
//  TSKReportView.m
//  Taskation
//
//  Created by Lyndsey on 12/21/08.
//  Copyright 2008 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKReportView.h"

const NSString* TSKKeySegmentPath = @"path";
const NSString* TSKKeySegmentColor = @"color";
const NSString* TSKKeySegmentText = @"text";
const NSString* TSKKeySegmentTextPointX = @"text.x";
const NSString* TSKKeySegmentTextPointY = @"text.y";

const CGFloat TSKChartBoundsInset = 20.0;

@implementation TSKReportView

// ----------------------------------------------------------------------------

-(NSColor *)randomColor
{
	
	float red = (50.0 + (random() % (1 + 50)))/100.0;
	float green = (50.0 + (random() % (1 + 50)))/100.0;
	float blue = (50.0 + (random() % (1 + 50)))/100.0;
	float alpha = 1.0;
	
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

// ----------------------------------------------------------------------------

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		scaleFactor = 1.0;
		textAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [NSColor whiteColor], NSBackgroundColorAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:12], NSFontAttributeName, nil];
		segmentShadow = [[NSShadow alloc] init];
		[segmentShadow setShadowOffset:NSMakeSize(3.0, -3.0)];
		[segmentShadow setShadowBlurRadius:5.0];
		[segmentShadow setShadowColor:[[NSColor blackColor]
								   colorWithAlphaComponent:0.5]];

    }
    return self;
}

// ----------------------------------------------------------------------------

- (void)updateSegmentColors
{
	NSUInteger segmentCount = [reportData count];
	if (segmentCount > 0) {
		colorsArray = [[NSMutableArray alloc] initWithCapacity:segmentCount];
		
		for (NSUInteger i = 0; i < segmentCount; i++) {
			[colorsArray addObject:[self randomColor]];
		}
	}
	else {
		[colorsArray release];
		colorsArray = nil;
	}
}

// ----------------------------------------------------------------------------

- (NSRect)squareAndCenterRect:(NSRect)rect
{
	NSRect viewRect = [self bounds];
	
	if(rect.size.width > rect.size.height) {
		rect.size.width = rect.size.height;
	}
	else if(rect.size.height > rect.size.width) {
		rect.size.height = rect.size.width;
	}
	rect.origin.x = (viewRect.size.width - rect.size.width)/2;
	rect.origin.y = (viewRect.size.height - rect.size.height)/2;
	
	return rect;
}

// ----------------------------------------------------------------------------

- (void)quarterRectsFromRect:(NSRect)rect
				 topLeftRect:(NSRect*)topLeft
				topRightRect:(NSRect*)topRight
			  bottomLeftRect:(NSRect*)bottomLeft
			 bottomRightRect:(NSRect*)bottomRight
{
	NSRect leftHalf;
	NSRect rightHalf;
	
	NSDivideRect(rect, &leftHalf, &rightHalf, (rect.size.width / 2), NSMinXEdge);

	NSDivideRect(leftHalf, topLeft, bottomLeft, (rect.size.height / 2), NSMinYEdge);
	NSDivideRect(rightHalf, topRight, bottomRight, (rect.size.height / 2), NSMinYEdge);
}

// ----------------------------------------------------------------------------

- (NSPoint)offsetTextPoint:(NSPoint)textPoint
					  size:(NSSize)textSize
				  inBounds:(NSRect)bounds
{
	NSRect chartBounds = NSInsetRect(bounds, TSKChartBoundsInset, TSKChartBoundsInset);
	
	const CGFloat TSKTextPadding = 5.0;

	NSRect topLeftBounds;
	NSRect topRightBounds;
	NSRect bottomLeftBounds;
	NSRect bottomRightBounds;
	
	[self quarterRectsFromRect:chartBounds
				   topLeftRect:&topLeftBounds
				  topRightRect:&topRightBounds
				bottomLeftRect:&bottomLeftBounds
			   bottomRightRect:&bottomRightBounds];
	
	if(NSPointInRect(textPoint, topLeftBounds)) {
		textPoint.y -= (textSize.height + TSKTextPadding);
		textPoint.x -= (textSize.width + TSKTextPadding);
	}
	else if(NSPointInRect(textPoint, topRightBounds)) {
		textPoint.y -= (textSize.height + TSKTextPadding);
		textPoint.x += TSKTextPadding;
	}
	else if(NSPointInRect(textPoint, bottomLeftBounds)) {
		textPoint.y += TSKTextPadding;
		textPoint.x -= (textSize.width + TSKTextPadding);
	}
	else if(NSPointInRect(textPoint, bottomRightBounds)) {
		textPoint.y += TSKTextPadding;
		textPoint.x += TSKTextPadding;
	}
	
	// Make sure the point isn't outside the view's bounds
	if(textPoint.x < bounds.origin.x + TSKTextPadding) {
		textPoint.x = bounds.origin.x + TSKTextPadding;
	}
	
	if((textPoint.x + textSize.width) > (bounds.origin.x + bounds.size.width - TSKTextPadding)) {
		textPoint.x = bounds.origin.x + bounds.size.width - textSize.width - TSKTextPadding;
	}
	
	if(textPoint.y < bounds.origin.y + TSKTextPadding) {
		textPoint.y = bounds.origin.y + TSKTextPadding;
	}
	
	if((textPoint.y + textSize.height) > (bounds.origin.y + bounds.size.height - TSKTextPadding)) {
		textPoint.y = bounds.origin.y + bounds.size.height - textSize.height - TSKTextPadding;
	}
	return textPoint;
}

// ----------------------------------------------------------------------------

- (void)updateDrawingData
{
	const CGFloat TSKSegmentOffset = 3.0;
	
	NSUInteger segmentCount = [reportData count];
	if (segmentCount > 0) {
		NSUInteger totalTime = 0;
		
		for (NSNumber* activityTime in [reportData allValues]) {
			totalTime += [activityTime intValue];
		}
		
		if (totalTime > 0) {
			[segments release];
			segments = [[NSMutableArray alloc] initWithCapacity:segmentCount];
			
			NSRect bounds = [self bounds];
			NSRect chartBounds = NSInsetRect(bounds, TSKChartBoundsInset, TSKChartBoundsInset);
			chartBounds.size.width -= chartBounds.size.width * 0.25;
			chartBounds.size.height -= chartBounds.size.height * 0.25;
			
			chartBounds = [self squareAndCenterRect:chartBounds];
			
			// Calculate how big a 'unit' is
			float unitSize = (360.0 / totalTime);
			if (unitSize > 360.0) {
				unitSize = 360.0;
			}
			
			float radius = chartBounds.size.width / 2;
			NSPoint centerPoint = NSMakePoint(NSMidX(chartBounds), NSMidY(chartBounds));
			
			float theCurrentAngle = 0.0;
			
			NSUInteger itemIndex = 0;
			for (NSString* itemKey in [reportData allKeys]) {
				NSUInteger itemTime = [[reportData objectForKey:itemKey] intValue];
				
				float theStartAngle = theCurrentAngle;
				theCurrentAngle += (itemTime * unitSize);
				float theEndAngle = theCurrentAngle;
				float theMidwayAngle = theStartAngle + ((theEndAngle - theStartAngle)/2);
				
				NSBezierPath* segmentPath = [NSBezierPath bezierPath];
				[segmentPath moveToPoint:centerPoint];
				[segmentPath appendBezierPathWithArcWithCenter:centerPoint
														radius:radius
													startAngle:theStartAngle
													  endAngle:theMidwayAngle
													 clockwise:NO];
				
				NSPoint textPoint = [segmentPath currentPoint];
				
				[segmentPath appendBezierPathWithArcWithCenter:centerPoint
														radius:radius
													startAngle:theMidwayAngle
													  endAngle:theEndAngle
													 clockwise:NO];
				[segmentPath closePath];
				[segmentPath setLineWidth:2.0];
				
				float differenceRatio = (TSKSegmentOffset / radius) + (TSKSegmentOffset / (theEndAngle - theStartAngle));
				float diffY = (textPoint.y - centerPoint.y) * differenceRatio;
				float diffX = (textPoint.x - centerPoint.x) * differenceRatio;
				
				NSAffineTransform* transform = [NSAffineTransform transform];
				[transform translateXBy:diffX yBy:diffY];
				[segmentPath transformUsingAffineTransform:transform];
				
				textPoint = [transform transformPoint:textPoint];
				
				NSMutableDictionary* segmentDict = [NSMutableDictionary dictionaryWithObject:segmentPath
																					  forKey:TSKKeySegmentPath];
				
				[segmentDict setObject:[colorsArray objectAtIndex:itemIndex]
								forKey:TSKKeySegmentColor];
				
				NSSize textSize = [itemKey sizeWithAttributes:textAttributes];
				textPoint = [self offsetTextPoint:textPoint size:textSize inBounds:bounds];
				
				if ((textPoint.x + textSize.width) > (chartBounds.origin.x + chartBounds.size.width)) {
					textPoint.x -= ((textPoint.x + textSize.width) - (chartBounds.origin.x + chartBounds.size.width));
				}
				NSString* segmentText = [NSString stringWithFormat:@"%.2f%% - %@", (100.0 * (float) itemTime / (float) totalTime), itemKey];
				
				[segmentDict setObject:segmentText
								forKey:TSKKeySegmentText];				
				[segmentDict setObject:[NSNumber numberWithFloat:textPoint.x]
								forKey:TSKKeySegmentTextPointX];
				[segmentDict setObject:[NSNumber numberWithFloat:textPoint.y]
								forKey:TSKKeySegmentTextPointY];
				
				[segments addObject:segmentDict];
				itemIndex++;
			}
		}
	}
	else {
		[segments release];
		segments = nil;
	}
}

// ----------------------------------------------------------------------------

- (void)drawChartSegment:(NSBezierPath*)path
			   withFillColor:(NSColor*)fillColor
{
	[NSGraphicsContext saveGraphicsState];
	[segmentShadow set];

	[[NSColor blackColor] set];
	[path stroke];
	[NSGraphicsContext restoreGraphicsState];

	[fillColor set];
	[path fill];
}

// ----------------------------------------------------------------------------

- (void)drawRect:(NSRect)rect
{
	[[NSColor whiteColor] set]; // white background
	NSRect bounds = [self bounds];
	
	[NSBezierPath fillRect:bounds];
	
	if([self inLiveResize]) {
		[self updateDrawingData];
	}
	
	for (NSDictionary* segmentDict in segments) {		
		[self drawChartSegment:[segmentDict objectForKey:TSKKeySegmentPath]
				 withFillColor:[segmentDict objectForKey:TSKKeySegmentColor]];
	}
	for (NSDictionary* segmentDict in segments) {		
			NSPoint textPoint = NSMakePoint([[segmentDict objectForKey:TSKKeySegmentTextPointX] floatValue], [[segmentDict objectForKey:TSKKeySegmentTextPointY] floatValue]);
		NSString* text = [segmentDict objectForKey:TSKKeySegmentText];
		
		[textAttributes setObject:[segmentDict objectForKey:TSKKeySegmentColor] forKey:NSBackgroundColorAttributeName];
		[text drawAtPoint:textPoint withAttributes:textAttributes];
	}
	if ([[NSGraphicsContext currentContext] isDrawingToScreen]) {
		[[NSColor grayColor] set];
		[NSBezierPath strokeRect:bounds];
	}
}

// ----------------------------------------------------------------------------

- (void)setReportScale:(CGFloat)aScaleFactor
{
	if (aScaleFactor != scaleFactor) {
		scaleFactor = aScaleFactor;
		
		NSFont* font = [NSFont systemFontOfSize:(12.0 * aScaleFactor)];
		[textAttributes setValue:font forKey:NSFontAttributeName];
		
		[self updateDrawingData];
		[self setNeedsDisplay:YES];
		[[self superview] setNeedsDisplay:YES];
	}
}
// ----------------------------------------------------------------------------

- (void)setReportData:(NSDictionary*)data
{
	[reportData release];
	reportData = [data retain];
	[self updateSegmentColors];
	[self updateDrawingData];
	[self setNeedsDisplay:YES];
	[[self superview] setNeedsDisplay:YES];
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[segmentShadow release];
	[colorsArray release];
	[reportData release];
	[textAttributes release];
	[super dealloc];
}
@end
