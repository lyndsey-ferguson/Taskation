//
//  TSKElapsedTimeFormatter.m
//  Taskation
//
//  Created by Lyndsey on 12/16/08.
//  Copyright 2008 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKElapsedTimeFormatter.h"

const NSUInteger TSKSecondsInADay = 86400;
const NSUInteger TSKSecondsInAnHour = 3600;
const NSUInteger TSKSecondsInAMinute = 60;

@implementation TSKElapsedTimeFormatter

// ----------------------------------------------------------------------------

- (NSString*)stringForObjectValue:(id)anObject
{
	NSUInteger elapsedTimeInSeconds = [anObject intValue];
		
	NSUInteger days    = (NSUInteger) (elapsedTimeInSeconds / TSKSecondsInADay); 
	NSUInteger hours   = (NSUInteger) ((elapsedTimeInSeconds % TSKSecondsInADay) / TSKSecondsInAnHour); 
	NSUInteger minutes = (NSUInteger) ((elapsedTimeInSeconds % TSKSecondsInAnHour) / TSKSecondsInAMinute); 
	NSUInteger seconds = (elapsedTimeInSeconds % 60);
	
	
	return [NSString stringWithFormat:@"%0.1d:%0.2d:%0.2d:%0.2d", days, hours, minutes, seconds];
}

// ----------------------------------------------------------------------------

- (BOOL)elapsedTimeDays:(NSInteger*)theDays
					 hours:(NSInteger*)theHours
				   minutes:(NSInteger*)theMinutes
				   seconds:(NSInteger*)theSeconds
		   fromString:(id)string
{
	BOOL gotValidTime = NO;
	@try {
		NSScanner* elapsedTimeScanner = [NSScanner scannerWithString:string];
		
		gotValidTime = [elapsedTimeScanner scanInteger:theDays];
		if (gotValidTime) {
			[elapsedTimeScanner setScanLocation:[elapsedTimeScanner scanLocation] + 1];
			gotValidTime = [elapsedTimeScanner scanInteger:theHours];
		}
		
		if (gotValidTime) {
			[elapsedTimeScanner setScanLocation:[elapsedTimeScanner scanLocation] + 1];
			gotValidTime = [elapsedTimeScanner scanInteger:theMinutes];
		}
		if (gotValidTime) {
			[elapsedTimeScanner setScanLocation:[elapsedTimeScanner scanLocation] + 1];
			gotValidTime = [elapsedTimeScanner scanInteger:theSeconds];
		}
		if (gotValidTime) {
			gotValidTime = [elapsedTimeScanner isAtEnd];
		}
	}
	@catch (id e) {
		gotValidTime = NO;
	}
	return gotValidTime;
}

// ----------------------------------------------------------------------------

- (BOOL)getObjectValue:(id*)anObject
			 forString:(NSString*)string
	  errorDescription:(NSString**)error
{
	
	NSInteger theDays    = 0; 
	NSInteger theHours   = 0; 
	NSInteger theMinutes = 0; 
	NSInteger theSeconds = 0;
 		
	
	BOOL isValidElapsedTime = [self elapsedTimeDays:&theDays hours:&theHours minutes:&theMinutes seconds:&theSeconds fromString:string];
	
	if (isValidElapsedTime) {
		*anObject = [NSNumber numberWithInt:((theDays * TSKSecondsInADay) + (theHours * TSKSecondsInAnHour) + (theMinutes * TSKSecondsInAMinute) + theSeconds)];
	}
	
	return isValidElapsedTime;
}

// ----------------------------------------------------------------------------

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject
								 withDefaultAttributes:(NSDictionary *)attributes
{
	return [[[NSAttributedString alloc] initWithString:[self stringForObjectValue:anObject] attributes:attributes] autorelease];
}

// ----------------------------------------------------------------------------

- (BOOL)pinTimeString:(NSString**)timeString toMaxValue:(int)maxValue
{
	BOOL wasValid = YES;
	
	if (nil == *timeString) {
		*timeString = @"00";
		wasValid = NO;
	}
	else {
		if ([*timeString length] > 2) {
			*timeString = [*timeString substringToIndex:2];
			wasValid = NO;
		}
		else if ([*timeString length] < 2) {
			*timeString = [*timeString stringByAppendingString:@"0"];
			wasValid = NO;
		}
		else {
			*timeString = [*timeString copy];
		}
		if ([*timeString intValue] > maxValue) {
			*timeString = [NSString stringWithFormat:@"%d", maxValue];
			wasValid = NO;
		}
	}
	
	return wasValid;
}

// ----------------------------------------------------------------------------

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error
{
	BOOL isValid = YES;
	NSUInteger lengthOfPartial = [partialString length];
	
	NSCharacterSet* validChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
	NSCharacterSet* validCharsWithDelimiters = [NSCharacterSet characterSetWithCharactersInString:@":0123456789"];
	NSCharacterSet* delimiters = [NSCharacterSet characterSetWithCharactersInString:@":"];
	
	NSCharacterSet* invalidChars = [validCharsWithDelimiters invertedSet];
		
	if (lengthOfPartial == 0) {
		*newString = @"0:00:00:00";
		isValid = NO;
	}
	if (isValid && [partialString rangeOfCharacterFromSet:invalidChars options:NSLiteralSearch].location != NSNotFound) {
		*error = @"An elapsed time string must consist of only numbers and colons";
		isValid = NO;
	}
	if (isValid) {
		NSString* delimiterString = nil;
		NSString* daysString = nil;
		NSString* hoursString = nil;
		NSString* minutesString = nil;
		NSString* secondsString = nil;
		
		NSScanner* scanner = [NSScanner scannerWithString:partialString];
		
		isValid = [scanner scanUpToString:@":" intoString:&daysString];
		if (isValid) {
			isValid = [scanner scanCharactersFromSet:delimiters intoString:&delimiterString];
			
			if (isValid) {
				isValid = [scanner scanUpToString:@":" intoString:&hoursString];
				
				if (isValid) {
					isValid = [scanner scanCharactersFromSet:delimiters intoString:&delimiterString];
					
					if (isValid) {
						isValid = [scanner scanUpToString:@":" intoString:&minutesString];
						if (isValid) {
							isValid = [scanner scanCharactersFromSet:delimiters intoString:&delimiterString];
							
							if (isValid) {
								isValid = [scanner scanCharactersFromSet:validChars intoString:&secondsString];
							}
						}
						else {
							NSUInteger minutesStringLength = ([partialString length] - [scanner scanLocation]);
							minutesString = [partialString substringWithRange:NSMakeRange([scanner scanLocation], minutesStringLength)];
						}
					}
				}
				else {
					NSUInteger hoursStringLength = ([partialString length] - [scanner scanLocation]);
					hoursString = [partialString substringWithRange:NSMakeRange([scanner scanLocation], hoursStringLength)];
				}
			}
		}
		else {
			daysString = partialString;
		}
		isValid = [self pinTimeString:&hoursString toMaxValue:23] && isValid;
		isValid = [self pinTimeString:&minutesString toMaxValue:59] && isValid;
		isValid = [self pinTimeString:&secondsString toMaxValue:59] && isValid;
		
		*newString = [NSString stringWithFormat:@"%@:%@:%@:%@", daysString, hoursString, minutesString, secondsString];
	}
	return isValid;
}

@end
