//
//  TSKPrintData.m
//  Taskation
//
//  Created by Lyndsey on 4/8/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKPrintData.h"


@implementation TSKPrintData

- (id)initWithRect:(NSRect)aRect
{
	self = [super init];
	if (self) {
		rect = aRect;
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)draw
{
	[NSException raise:@"Invalid Call" format:@"TSKPrintData's drawAtPoint should not be called directly"];
}

// ----------------------------------------------------------------------------

- (NSRect)rect
{
	return rect;
}

// ----------------------------------------------------------------------------

- (void)setRect:(NSRect)aRect
{
	rect = aRect;
}

@end
