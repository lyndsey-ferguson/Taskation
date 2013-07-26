//
//  TSKLicenseKeyComponentFormatter.m
//  Taskation
//
//  Created by Lyndsey on 2/10/10.
//  Copyright 2010 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKLicenseKeyComponentFormatter.h"


@implementation TSKLicenseKeyComponentFormatter


- (id)init
{
	self = [super init];
	if (self) {
		NSMutableCharacterSet* validCharacterSet = [NSMutableCharacterSet decimalDigitCharacterSet];
		[validCharacterSet addCharactersInString:@"ABCDEF"];
		
		invalidLicenseCharacterSet = [[validCharacterSet invertedSet] retain];
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[invalidLicenseCharacterSet release];
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (NSString*)stringForObjectValue:(id)anObject
{
	return [(NSString*)anObject uppercaseString];
}

// ----------------------------------------------------------------------------

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject
								 withDefaultAttributes:(NSDictionary *)attributes
{
	return [[[NSAttributedString alloc] initWithString:[self stringForObjectValue:anObject]
										   attributes:attributes] autorelease];  
}

// ----------------------------------------------------------------------------

- (BOOL)getObjectValue:(id*)anObject
			 forString:(NSString*)string
	  errorDescription:(NSString**)error
{
	*anObject = [NSString stringWithString:string];
	
	return YES;
}

// ----------------------------------------------------------------------------

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error
{
	BOOL isValid = NO;
	
	if ([partialString length] < 5) {		
		NSRange invalidCharacterRange = [[partialString uppercaseString] rangeOfCharacterFromSet:invalidLicenseCharacterSet];
		
		isValid = (invalidCharacterRange.length == 0);
	}
	return isValid;
}
@end
