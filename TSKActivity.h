//
//  TSKTask.h
//  Taskation
//
//  Created by Lyndsey on 9/27/08.
//  Copyright 2008 Lyndsey D. Ferguson All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKDefinitions;

@interface TSKActivity : NSObject <NSCoding> {
	NSString*				actionID;
	NSString*				subjectID;
	NSDate*					startTime;
	NSDate*					endTime;
	
	TSKDefinitions* definitions;
	
	NSMutableArray*			notes;
	
	NSTimer*				timer;
	BOOL					isInProgress;
}

@property (retain) NSMutableArray* notes;
@property (retain) TSKDefinitions* definitions;

- (id)initWithActionID:(NSString*)theActionID
		  subjectID:(NSString*)theSubjectID
andDefinitions:(TSKDefinitions*)theDefinitions;

- (id)initWithActionID:(NSString*)theActionID
			 subjectID:(NSString*)theSubjectID
			 startTime:(NSDate*)theStartTime
   andDefinitions:(TSKDefinitions*)theDefinitions;

- (id)initWithActionID:(NSString*)theActionID
			 subjectID:(NSString*)theSubjectID
			 startTime:(NSDate*)theStartTime
			   endTime:(NSDate*)theEndTime
   andDefinitions:(TSKDefinitions*)theDefinitions;

- (void)setSubjectID:(NSString*)theSubjectID;

- (NSString*)action;
- (NSString*)subject;
- (NSDate*)startTime;
- (NSNumber*)elapsedTime;
- (NSDate*)endDate;

- (BOOL)isInProgress;
- (void)stop;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

- (unsigned int)countOfNotes;

- (NSString*)objectInNotesAtIndex:(unsigned int)index;

@end
