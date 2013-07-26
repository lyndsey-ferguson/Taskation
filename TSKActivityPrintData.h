//
//  TSKActivityPrintData.h
//  Taskation
//
//  Created by Lyndsey on 4/8/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKPrintData.h"

#define kHeaderColumnCount 5
#define kHeaderCellPadding 5.0

@class TSKActivity;

@interface TSKActivityPrintData : TSKPrintData {
	TSKActivity* activity;
}
+ (CGFloat)requiredHeight;

- (id)initWithActivity:(TSKActivity*)anActivity andRect:(NSRect)aRect;
@end // TSKActivityPrintData
