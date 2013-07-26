//
//  TSKTask.m
//  Taskation
//
//  Created by Lyndsey on 9/27/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import "TSKActivity.h"
#import "TSKCommonConstants.h"
#import "TSKDefinitions.h"

typedef enum
{
	eDateComponent_Day,
	eDateComponent_Month,
	eDateComponent_Year
} TSKDateComponent;

unsigned char markChar = INVALID_LICENSE_BYTE1;

// ============================================================================

@implementation TSKActivity

@synthesize notes;
@synthesize definitions;

- (id)initWithActionID:(NSString*)theActionID
			 subjectID:(NSString*)theSubjectID
			 startTime:(NSDate*)theStartTime
			   endTime:(NSDate*)theEndTime
   andDefinitions:(TSKDefinitions*)theDefinitions
{
	self = [super init];
	
	actionID = [theActionID retain];
	subjectID = [theSubjectID retain];
	startTime = [theStartTime retain];
	endTime = [theEndTime retain];
	definitions = [theDefinitions retain];
	
	isInProgress = (nil == endTime);
	
	if (isInProgress) {
		timer = [[NSTimer scheduledTimerWithTimeInterval:1.0
												  target:self
												selector:@selector(incrementEndTime:)
												userInfo:nil
												 repeats:YES] retain];
	}
	
	notes = [[NSMutableArray alloc] initWithObjects:[NSMutableString stringWithString:@""], nil];
	
	return self;
}

// ----------------------------------------------------------------------------

- (id)initWithActionID:(NSString*)theActionID
			 subjectID:(NSString*)theSubjectID
			 startTime:(NSDate*)theStartTime
   andDefinitions:(TSKDefinitions*)theDefinitions
{
	return [self initWithActionID:theActionID
						subjectID:theSubjectID
						startTime:theStartTime
						  endTime:nil
			  andDefinitions:theDefinitions];
}

// ----------------------------------------------------------------------------

- (id)initWithActionID:(NSString*)theActionID
			 subjectID:(NSString*)theSubjtectID
   andDefinitions:(TSKDefinitions*)theDefinitions
{
	return [self initWithActionID:theActionID
						subjectID:theSubjtectID
						startTime:[[NSDate alloc] initWithTimeIntervalSinceNow:0]
						  endTime:nil
			  andDefinitions:theDefinitions];
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[timer invalidate];
	[timer release];
	[startTime release];
	[endTime release];
	[actionID release];
	[subjectID release];
	[notes release];
	[definitions release];
	
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (void)incrementEndTime:(NSTimer*)theTimer
{
	NSDate* newEndTime = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
	
	[self setValue:newEndTime forKey:@"endTime"];
}

// ----------------------------------------------------------------------------

- (void)setSubjectID:(NSString*)theSubjectID
{
	[subjectID release];
	subjectID = [theSubjectID retain];
}

// ----------------------------------------------------------------------------

- (NSString*)action
{
	return [definitions actionForActionID:actionID];
}

// ----------------------------------------------------------------------------

- (NSString*)subject
{
	return [definitions subjectForSubjectID:subjectID];
}

// ----------------------------------------------------------------------------

- (NSDate*)startTime
{
	return startTime;
}

// ----------------------------------------------------------------------------

- (void)setEndTime:(NSDate*)anEndTime
{
	[endTime release];
	endTime = [anEndTime retain];
}

// ----------------------------------------------------------------------------

- (NSDate*)endTime
{
	NSDate* reportedEndTime = nil;
	if (![self isInProgress]) {
		reportedEndTime = endTime;
	}
	return reportedEndTime;
}

// ----------------------------------------------------------------------------

- (NSDate*)startDate
{
	return startTime;
}

// ----------------------------------------------------------------------------

- (NSDate*)endDate
{
	NSDate* end = startTime;
	
	if (NO == [self isInProgress]) {
		end = endTime;
	}
	return end;
}

// ----------------------------------------------------------------------------

- (NSNumber*)elapsedTime
{
	NSTimeInterval elapsedTimeInterval = [endTime timeIntervalSinceDate:startTime];
	
	NSNumber* time = [NSNumber numberWithInt:(NSInteger)elapsedTimeInterval];
	return time;
}

// ----------------------------------------------------------------------------

- (BOOL)isInProgress
{
	return isInProgress;
}

// ----------------------------------------------------------------------------

- (void)stop
{
	if ([self isInProgress]) {
		[timer invalidate];
		[timer release];
		
		isInProgress = NO;
		
		endTime = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
	}
}

// ----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:actionID forKey:@"actionID"];
	[aCoder encodeObject:subjectID forKey:@"subjectID"];
	[aCoder encodeObject:startTime forKey:@"startTime"];
	[aCoder encodeObject:endTime forKey:@"endTime"];
	[aCoder encodeObject:notes forKey:@"notes"];
	[aCoder encodeObject:[NSNumber numberWithBool:isInProgress] forKey:@"isInProgress"];
}

// ----------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	
	actionID = [[aDecoder decodeObjectForKey:@"actionID"] retain];
	subjectID = [[aDecoder decodeObjectForKey:@"subjectID"] retain];
	startTime = [[aDecoder decodeObjectForKey:@"startTime"] retain];
	endTime = [[aDecoder decodeObjectForKey:@"endTime"] retain];
	notes = [[aDecoder decodeObjectForKey:@"notes"] retain];
	isInProgress = [(NSNumber*)[aDecoder decodeObjectForKey:@"isInProgress"] boolValue];
	
	if (isInProgress) {
		timer = [[NSTimer scheduledTimerWithTimeInterval:1.0
												  target:self
												selector:@selector(incrementEndTime:)
												userInfo:nil
												 repeats:YES] retain];
	}
	
	return self;
}

// ----------------------------------------------------------------------------

- (unsigned int)countOfNotes {
	return [notes count];
}

// ----------------------------------------------------------------------------

- (NSString*)objectInNotesAtIndex:(unsigned int)index {
	return [notes objectAtIndex:index];
}

@end
