//
//  TSKUUIDStringCategory.m
//  Taskation
//
//  Created by Lyndsey on 1/25/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKUUIDStringCategory.h"


@implementation NSString ( UniversallyUniqueIdentifier )

+ (NSString*)uuidString;

{
	NSString* uuidString = nil;
	
	CFUUIDRef cfUUID = CFUUIDCreate(kCFAllocatorDefault);
	if (cfUUID) {
		uuidString = [(NSString*) CFUUIDCreateString(kCFAllocatorDefault, cfUUID) autorelease];
		CFRelease(cfUUID);
	}
	return uuidString;
}

@end
