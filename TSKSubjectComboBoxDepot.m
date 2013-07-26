//
//  TSKSubjectComboBoxDepot.m
//  Taskation
//
//  Created by Lyndsey on 1/18/09.
//  Copyright 2009 Lyndsey D. Ferguson All rights reserved.
//

#import "TSKSubjectComboBoxDepot.h"
#import "TSKDefinitions.h"


@implementation TSKSubjectComboBoxDepot

- (id)initWithDefinitions:(TSKDefinitions*)theDefinitions
				andActionComboBox:(NSComboBox*)comboBox{
	self = [super init];
	if (self) {
		activityDefinitions = [theDefinitions retain];
		actionComboBox = [comboBox retain];
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[activityDefinitions release];
	[actionComboBox release];
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (NSArray*)subjectDicts
{
	NSString* action = [actionComboBox stringValue];
	NSString* actionID = [activityDefinitions actionIDForAction:action];
	return [activityDefinitions subjectsForActionID:actionID];
}

// ----------------------------------------------------------------------------

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	return [activityDefinitions subjectAtIndex:index forAction:[actionComboBox stringValue]];
}

// ----------------------------------------------------------------------------

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	return [activityDefinitions subjectCountForAction:[actionComboBox stringValue]];
}

// ----------------------------------------------------------------------------

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString
{
	NSDictionary* matchingSubjectDict = [activityDefinitions closestMatchingSubject:uncompletedString
																		  forAction:[actionComboBox stringValue]];
	return [matchingSubjectDict objectForKey:TSK_KEY_NAME];
}

// ----------------------------------------------------------------------------

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString
{
	NSDictionary* matchingSubjectDict = [activityDefinitions closestMatchingAction:aString];
	return [(NSNumber*)[matchingSubjectDict objectForKey:TSK_KEY_SUBJECT_INDEX] unsignedIntValue];
}

@end
