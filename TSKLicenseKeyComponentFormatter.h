//
//  TSKLicenseKeyComponentFormatter.h
//  Taskation
//
//  Created by Lyndsey on 2/10/10.
//  Copyright 2010 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TSKLicenseKeyComponentFormatter : NSFormatter {
	NSCharacterSet* invalidLicenseCharacterSet;
}
- (NSString*)stringForObjectValue:(id)anObject;

- (BOOL)getObjectValue:(id*)anObject
			 forString:(NSString*)string
	  errorDescription:(NSString**)error;

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject
								 withDefaultAttributes:(NSDictionary *)attributes;

- (BOOL)isPartialStringValid:(NSString *)partialString
			newEditingString:(NSString **)newString
			errorDescription:(NSString **)error;

@end
