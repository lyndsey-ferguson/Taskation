//
//  TSKElapsedTimeFormatter.h
//  Taskation
//
//  Created by Lyndsey on 12/16/08.
//  Copyright 2008 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TSKElapsedTimeFormatter : NSFormatter {

}

- (NSString*)stringForObjectValue:(id)anObject;

- (BOOL)getObjectValue:(id*)anObject
			 forString:(NSString*)string
	  errorDescription:(NSString**)error;

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject
								 withDefaultAttributes:(NSDictionary *)attributes;

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error;

@end
