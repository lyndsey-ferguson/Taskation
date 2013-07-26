//
//  TSKActionComboBoxDepot.m
//  Taskation
//
//  Created by Lyndsey on 1/17/09.
//  Copyright 2009 Lyndsey D. Ferguson All rights reserved.
//

#import "TSKActionComboBoxDepot.h"
#import "TSKDefinitions.h"

@implementation TSKActionComboBoxDepot

- (id)initWithDefinitions:(TSKDefinitions*)theDefinitions
{
	self = [super init];
	if (self) {
		activityDefinitions = [theDefinitions retain];
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[activityDefinitions release];
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	return [activityDefinitions actionAtIndex:index]; 
}

// ----------------------------------------------------------------------------

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	return [activityDefinitions actionCount];
}

// ----------------------------------------------------------------------------

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString
{
	NSDictionary* matchingActionDict = [activityDefinitions closestMatchingAction:uncompletedString];
	return [matchingActionDict objectForKey:TSK_KEY_NAME];
}

// ----------------------------------------------------------------------------

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString
{	
	NSDictionary* matchingActionDict = [activityDefinitions closestMatchingAction:aString];
	return [(NSNumber*)[matchingActionDict objectForKey:TSK_KEY_ACTION_INDEX] unsignedIntValue];
}

@end
