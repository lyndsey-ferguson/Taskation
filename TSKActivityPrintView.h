//
//  TSKActivityPrintView.h
//  Taskation
//
//  Created by Lyndsey on 3/25/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TSKActivityPrintView : NSView {
	NSMutableArray* printDataBlocks;
}

- (id)initWithActivityData:(NSArray*)activityData;

@end
