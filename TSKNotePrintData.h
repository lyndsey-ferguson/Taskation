//
//  TSKNotePrintData.h
//  Taskation
//
//  Created by Lyndsey on 4/8/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TSKPrintData.h"

#define kNoteRowIndent 20.0

@interface TSKNotePrintData : TSKPrintData {
	NSString* note;
}
+ (CGFloat)heightOfWrappedText:(NSString*)theText forWidth:(CGFloat)theWidth;

- (id)initWithNote:(NSString*)noteString andRect:(NSRect)aRect;

@end
