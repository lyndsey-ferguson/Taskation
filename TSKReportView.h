//
//  TSKReportView.h
//  Taskation
//
//  Created by Lyndsey on 12/21/08.
//  Copyright 2008 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TSKReportView : NSView {
	NSDictionary* reportData;
	NSMutableArray* segments;
	NSMutableArray* colorsArray;
	NSMutableDictionary* textAttributes;
	NSShadow* segmentShadow;
	CGFloat scaleFactor;
}

- (void)setReportScale:(CGFloat)aScaleFactor;
- (void)setReportData:(NSDictionary*)data;

@end
