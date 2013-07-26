//
//  TSKPrintData.h
//  Taskation
//
//  Created by Lyndsey on 4/8/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TSKPrintData : NSObject {
	NSRect rect;
}

- (id)initWithRect:(NSRect)aRect;
- (void)draw;
- (NSRect)rect;
- (void)setRect:(NSRect)aRect;

@end // TSKPrintData
