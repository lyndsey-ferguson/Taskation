//
//  TSKDefinitions.m
//  Taskation
//
//  Created by Lyndsey on 1/17/09.
//  Copyright 2009 Lyndsey D. Ferguson All rights reserved.
//

#import "TSKDefinitions.h"
#import "TSKUUIDStringCategory.h"

NSString* TSK_ACTION_ALL_SUBJECTS = @"****";
NSString* TSK_TABLEVIEW_EMPTY_STRING = @"";

@implementation TSKDefinitions

@synthesize actions;
@synthesize subjects;

- (NSMutableDictionary*)copyDeepActionDict:(NSDictionary*)anActionDict
{
	NSMutableDictionary* actionDict = nil;
	
	NSMutableArray* actionsSubjects = [[NSMutableArray alloc] init];
	
	for (NSString* subjectUUIDString in [anActionDict objectForKey:TSK_KEY_ACTION_SUBJECTS]) {
		NSString* subjectUUID = [[NSString alloc] initWithString:subjectUUIDString];
		[actionsSubjects addObject:subjectUUID];
	}
	
	actionDict = [[NSMutableDictionary alloc] init];
	[actionDict setObject:[anActionDict objectForKey:TSK_KEY_NAME] forKey:TSK_KEY_NAME];
	[actionDict setObject:actionsSubjects forKey:TSK_KEY_ACTION_SUBJECTS];
	
	return actionDict;
}

// ----------------------------------------------------------------------------

- (id)init
{
	self = [super init];
	if (self) {
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		
		actions = [[NSMutableDictionary alloc] init];			
		
		for (NSString* anActionID in [[defaults objectForKey:TSK_KEY_ACTIONS] allKeys]) {
			NSDictionary* anActionDict = [[defaults objectForKey:TSK_KEY_ACTIONS] objectForKey:anActionID];
			
			[actions setObject:[self copyDeepActionDict:anActionDict] forKey:anActionID];
		}
		
		subjects = [[defaults objectForKey:TSK_KEY_SUBJECTS] mutableCopy];
	}
	return self;
}

// ----------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		actions = [[aDecoder decodeObjectForKey:@"action_definitions"] retain];
		subjects = [[aDecoder decodeObjectForKey:@"subject_definitions"] retain];
	}
	
	return self;
}

// ----------------------------------------------------------------------------

- (id)initWithDefinitions:(TSKDefinitions*)originalDefinitions
{
	self = [super init];
	if (self) {
		actions = [[NSMutableDictionary alloc] init];			
	
		for (NSString* anActionID in [[originalDefinitions actions] allKeys]) {
			NSDictionary* anActionDict = [[originalDefinitions actions] objectForKey:anActionID];
			
			[actions setObject:[self copyDeepActionDict:anActionDict] forKey:anActionID];
		}
		
		subjects = [[originalDefinitions subjects] mutableCopy];
	}
	return self;
}

// ----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:actions forKey:@"action_definitions"];
	[aCoder encodeObject:subjects forKey:@"subject_definitions"];
}

// ----------------------------------------------------------------------------

- (void)dealloc
{
	[actions release];
	[subjects release];
	
	[super dealloc];
}

// ----------------------------------------------------------------------------

- (NSString*)addAction:(NSString*)anAction
{
	NSString* uuid = [self actionIDForAction:anAction];
	if (nil == uuid) {
		NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:anAction, TSK_KEY_NAME, [[NSMutableArray  alloc] init], TSK_KEY_ACTION_SUBJECTS, nil];
			
		uuid = [NSString uuidString];
		[actions setObject:dict forKey:uuid];
	}
	return uuid;
}

// ----------------------------------------------------------------------------

- (NSString*)subjectForSubjectID:(NSString*)aSubjectID
{
	return [subjects objectForKey:aSubjectID];
}

// ----------------------------------------------------------------------------

- (NSString*)actionForActionID:(NSString*)anActionID
{
	return [[actions objectForKey:anActionID] objectForKey:TSK_KEY_NAME];
}

// ----------------------------------------------------------------------------

- (NSString*)actionIDForAction:(NSString*)anAction
{
	NSString* theActionID = nil;

	NSString* actionToSearchFor = [anAction lowercaseString];
	BOOL hasAction = NO;
	
	for (NSString* anActionID in [actions allKeys]) {
		NSDictionary* anActionDict = [actions objectForKey:anActionID];
		
		NSString* actionToTest = [(NSString*)[anActionDict objectForKey:TSK_KEY_NAME] lowercaseString];
		
		if ([actionToSearchFor isEqualToString:actionToTest]) {
			theActionID = anActionID;
			hasAction = YES;
			break;
		}
	}
	
	
	return theActionID;
}

// ----------------------------------------------------------------------------

- (NSString*)actionAtIndex:(int)theIndex
{
	NSString* theAction = nil;	
	
	if ([actions count] > theIndex) {
		NSString* theActionID = [[actions allKeys] objectAtIndex:theIndex];
		
		NSDictionary* actionDict = [actions objectForKey:theActionID];
		theAction = [actionDict objectForKey:TSK_KEY_NAME];
	}
	
	return theAction;
}

// ----------------------------------------------------------------------------

- (NSString*)actionIDForActionAtIndex:(int)theIndex
{
	NSString* theActionID = nil;	
	
	if ([actions count] > theIndex) {
		theActionID = [[actions allKeys] objectAtIndex:theIndex];
	}
	return theActionID;
}

// ----------------------------------------------------------------------------

- (int)indexForActionID:(NSString*)anActionID
{
	int index = NSNotFound;
	
	NSString* actionIDToFind = [anActionID lowercaseString];
	
	int currentIndex = 0;
	for (NSString* actionID in [actions allKeys]) {
		actionID = [actionID lowercaseString];
		
		if ([actionIDToFind compare:actionID] == NSOrderedSame) {
			index = currentIndex;
		}
		currentIndex++;
	}
	
	return index;
}

// ----------------------------------------------------------------------------

- (BOOL)setAction:(NSString*)theAction atIndex:(int)theIndex
{
	BOOL wasActionSet = NO;
	if ([actions count] > theIndex) {
		NSString* theActionID = [[actions allKeys] objectAtIndex:theIndex];
		NSMutableDictionary* actionDict = [actions objectForKey:theActionID];
		[actionDict setObject:theAction forKey:TSK_KEY_NAME];
		wasActionSet = YES;
	}
	return wasActionSet;
}

// ----------------------------------------------------------------------------

- (BOOL)removeActionAtIndex:(int)theIndex
{
	BOOL wasActionRemoved = NO;
	if ([actions count] > theIndex) {
		NSString* theActionID = [[actions allKeys] objectAtIndex:theIndex];
		
		if (theActionID) {
			[actions removeObjectForKey:theActionID];
			
			wasActionRemoved = YES;
		}
	}
	
	return wasActionRemoved;
}

// ----------------------------------------------------------------------------

- (NSUInteger)actionCount
{
	return [actions count];
}

// ----------------------------------------------------------------------------

- (NSDictionary*)closestMatchingAction:(NSString*)aPartialActionString
{	
	NSString* closestMatchingActionDesc = nil;
	NSNumber* closestMatchingActionIndex = nil;
	NSString* partialActionStringToLookFor = [aPartialActionString lowercaseString];
	
	NSUInteger index = 0;
	
	BOOL hasMatch = NO;
	
	for (NSString* anActionID in [actions allKeys]) {
		NSDictionary* actionDict = [actions objectForKey:anActionID];
		NSString* completeActionString = [(NSString*)[actionDict objectForKey:TSK_KEY_NAME] lowercaseString];
		
		if (0 == [completeActionString rangeOfString:partialActionStringToLookFor].location) {
			closestMatchingActionDesc = [actionDict objectForKey:TSK_KEY_NAME];
			closestMatchingActionIndex = [NSNumber numberWithUnsignedInt:index];
			hasMatch = YES;
			break;
		}
		index++;
	}
	
	NSDictionary* closestMatchingActionDict = nil;
	if (hasMatch) {
		closestMatchingActionDict = [NSDictionary dictionaryWithObjectsAndKeys:closestMatchingActionDesc, TSK_KEY_NAME, closestMatchingActionIndex, TSK_KEY_ACTION_INDEX, nil];
	}
	if (!hasMatch) {
		closestMatchingActionIndex = [NSNumber numberWithUnsignedInt:NSNotFound];
		closestMatchingActionDict = [NSDictionary dictionaryWithObjectsAndKeys:closestMatchingActionIndex, TSK_KEY_ACTION_INDEX, nil];
	}
	return closestMatchingActionDict;
}

// ----------------------------------------------------------------------------

- (NSString*)addSubject:(NSString*)subject
{
	NSString* uuid = [self subjectIDForSubject:subject];
	if (nil == uuid) {
		uuid = [NSString uuidString];
		[subjects setObject:subject forKey:uuid];
	}
	return uuid;
}

// ----------------------------------------------------------------------------

- (BOOL)associateSubject:(NSString*)aSubjectID
			   withAction:(NSString*)anActionID
{
	NSString* actionDesc = [self actionForActionID:anActionID];
	
	BOOL doesActionExist = (actionDesc != nil);
	
	BOOL isAssociated = NO;
	
	if (doesActionExist) {
		NSMutableDictionary* actionDict = [actions objectForKey:anActionID];
		NSMutableArray* currentSubjects = [actionDict objectForKey:TSK_KEY_ACTION_SUBJECTS];
		
		isAssociated = ([currentSubjects containsObject:aSubjectID]);
		if (!isAssociated) {
			[currentSubjects addObject:aSubjectID];
			isAssociated = YES;
		}
	}
	return isAssociated;
}

// ----------------------------------------------------------------------------

- (NSDictionary*)subjectDictForSubjectID:(NSString*)aSubjectID
{
	NSDictionary* subjectDict = nil;
	
	NSString* subjectDesc = [self subjectForSubjectID:aSubjectID];
	if (subjectDesc) {
		subjectDict = [[NSDictionary alloc] initWithObjectsAndKeys:aSubjectID, TSK_KEY_SUBJECT_IDENTIFIER, subjectDesc, TSK_KEY_NAME, nil];
	}
	
	return [subjectDict autorelease];
}

// ----------------------------------------------------------------------------

- (NSArray*)subjectsForActionID:(NSString*)anActionID
{
	NSMutableArray* assocSubjects = nil;
	
	NSDictionary* actionDict = [actions objectForKey:anActionID];
	NSArray* assocSubjectIDs = [actionDict objectForKey:TSK_KEY_ACTION_SUBJECTS];
	for (NSString* assocSubjectID in assocSubjectIDs) {
		if (assocSubjects == nil) {
			assocSubjects = [NSMutableArray arrayWithCapacity:[assocSubjectIDs count]];
		}
		NSDictionary* subjectDict = [self subjectDictForSubjectID:assocSubjectID];
		if (subjectDict) {
			[assocSubjects addObject:subjectDict];
		}
	}

	return [assocSubjects autorelease];
}

// ----------------------------------------------------------------------------

- (NSString*)subjectIDForSubject:(NSString*)subject;
{
	NSString* subjectToSearchFor = [subject lowercaseString];
	
	NSString* subjectUUID = nil;
	
	for (NSString* currentSubjectID in [subjects allKeys]) {
		NSString* subjectToTest = [[subjects objectForKey:currentSubjectID] lowercaseString];
		
		if (NSOrderedSame == [subjectToSearchFor compare:subjectToTest]) {
			subjectUUID = currentSubjectID;
			break;
		}
	}
	
	return subjectUUID;
}

// ----------------------------------------------------------------------------

- (NSString*)subjectAtIndex:(int)theIndex
			  forAction:(NSString*)anAction
{
	NSString* nthSubject = nil;
	
	BOOL shouldGetNthFromAll = (TSK_ACTION_ALL_SUBJECTS == anAction);
	
	if (shouldGetNthFromAll) {
		nthSubject = [[subjects allValues] objectAtIndex:theIndex];
	}
	else {
		NSString* actionID = [self actionIDForAction:anAction];
		NSDictionary* actionDict = [actions objectForKey:actionID];
		
		NSArray* assocSubjects = [actionDict objectForKey:TSK_KEY_ACTION_SUBJECTS];
		
		if ([assocSubjects count] > theIndex) {
			nthSubject = [subjects objectForKey:[assocSubjects objectAtIndex:theIndex]];
		}
	}
	
	return nthSubject;
}

// ----------------------------------------------------------------------------

- (BOOL)setSubject:(NSString*)aSubject
		   atIndex:(int)theIndex
	   forActionID:(NSString*)anActionID
{
	BOOL shouldSetForSpecificAction = (nil != anActionID);
	
	BOOL didSetSubject = NO;
	
	NSString* subjectID = [self subjectIDForSubject:aSubject];
	BOOL doesSubjectAlreadyExist = (nil != subjectID);
	
	if (!doesSubjectAlreadyExist) {
		if (!shouldSetForSpecificAction && !doesSubjectAlreadyExist) {
			subjectID = [[subjects allKeys] objectAtIndex:theIndex]; 
		}
		else {
			NSDictionary* actionDict = [actions objectForKey:anActionID];
			NSArray* assocSubjects = [actionDict objectForKey:TSK_KEY_ACTION_SUBJECTS];
			if ([assocSubjects count] > theIndex) {
				subjectID = [assocSubjects objectAtIndex:theIndex];
			}
		}
		if (subjectID) {
			[subjects setObject:aSubject forKey:subjectID];
			didSetSubject = YES;
		}
	}
	else if (shouldSetForSpecificAction && doesSubjectAlreadyExist) {
		NSDictionary* actionDict = [actions objectForKey:anActionID];
		NSArray* assocSubjects = [actionDict objectForKey:TSK_KEY_ACTION_SUBJECTS];
		NSString* prevSubjectID = [assocSubjects objectAtIndex:theIndex];
		NSString* prevSubject = [subjects objectForKey:prevSubjectID];
		if (prevSubject == TSK_TABLEVIEW_EMPTY_STRING) {
			[subjects removeObjectForKey:prevSubjectID];
			[self removeSubjectAtIndex:theIndex forActionID:anActionID];
		}
		
		[subjects setObject:aSubject forKey:subjectID];
		[self associateSubject:subjectID withAction:anActionID];
		
		didSetSubject = YES;
	}
	return didSetSubject;
}

// ----------------------------------------------------------------------------

-  (int)indexOfSubjectID:(NSString*)aSubjectID forActionID:(NSString*)anActionID
{
	int theIndex = NSNotFound;
	
	BOOL shouldGetForSpecificAction = (nil != anActionID);

	if (shouldGetForSpecificAction) {
		NSDictionary* actionDict = [actions objectForKey:anActionID];
		NSArray* assocSubjects = [actionDict objectForKey:TSK_KEY_ACTION_SUBJECTS];
		theIndex = [assocSubjects indexOfObject:aSubjectID];
	}
	else {
		theIndex = [[subjects allKeys] indexOfObject:aSubjectID]; 
	}
	return theIndex;
}

// ----------------------------------------------------------------------------

- (BOOL)removeSubjectAtIndex:(int)theIndex
				 forActionID:(NSString*)anActionID
{
	BOOL shouldRemoveFromCompleteList = (nil == anActionID);
	
	BOOL didRemove = NO;
	if (shouldRemoveFromCompleteList) {
		NSString* subjectID = [[subjects allKeys] objectAtIndex:theIndex];
		[subjects removeObjectForKey:subjectID];
		
		for (NSDictionary* actionDict in [actions allValues]) {
			NSMutableArray* assocSubjects = [actionDict objectForKey:TSK_KEY_ACTION_SUBJECTS];
			[assocSubjects removeObject:subjectID];
		}
		didRemove = YES;
	}
	else {
		NSDictionary* actionDict = [actions objectForKey:anActionID];
		NSMutableArray* assocSubjects = [actionDict objectForKey:TSK_KEY_ACTION_SUBJECTS];
		
		if ([assocSubjects count] > theIndex) {
			[assocSubjects removeObjectAtIndex:theIndex];
			didRemove = YES;
		}
	}
	return didRemove;
}

// ----------------------------------------------------------------------------

- (NSUInteger)subjectCountForAction:(NSString*)anAction
{
	NSUInteger subjectCount = 0;
	
	BOOL shouldCountAllSubjects = (TSK_ACTION_ALL_SUBJECTS == anAction);
	if (shouldCountAllSubjects) {
		subjectCount = [subjects count];
	}
	else {
		NSString* actionID = [self actionIDForAction:anAction];
		NSDictionary* actionDict = [actions objectForKey:actionID];
		
		NSArray* assocSubjects = [actionDict objectForKey:TSK_KEY_ACTION_SUBJECTS];
		
		subjectCount = [assocSubjects count];
	}
	
	return subjectCount;
}

// ----------------------------------------------------------------------------

- (NSDictionary*)closestMatchingSubject:(NSString*)aPartialSubjectString
							  forAction:(NSString*)anAction
{
	NSString* closestMatchingSubjectDesc = nil;
	NSNumber* closestMatchingSubjectIndex = nil;
	
	NSDictionary* actionDict = [actions objectForKey:[self actionIDForAction:anAction]];
	NSArray* assocSubjects = [actionDict objectForKey:TSK_KEY_ACTION_SUBJECTS];
	
	NSString* partialSubjectStringToLookFor = [aPartialSubjectString lowercaseString];
	BOOL hasMatch = NO;
	
	NSUInteger index = 0;
	
	for (NSString* aSubjectID in assocSubjects) {		
		NSString* completeActionString = [(NSString*)[subjects objectForKey:aSubjectID] lowercaseString];
		
		if (0 == [completeActionString rangeOfString:partialSubjectStringToLookFor].location) {
			closestMatchingSubjectDesc = [subjects objectForKey:aSubjectID];
			closestMatchingSubjectIndex = [NSNumber numberWithUnsignedInt:index];
			hasMatch = YES;
			break;
		}
		index++;
	}
	
	NSDictionary* closedMatchingSubjectDict = nil;
	if (hasMatch) {
		closedMatchingSubjectDict = [NSDictionary dictionaryWithObjectsAndKeys:closestMatchingSubjectDesc, TSK_KEY_NAME, closestMatchingSubjectIndex, TSK_KEY_SUBJECT_INDEX, nil];
	}
	if (!hasMatch) {
		closestMatchingSubjectIndex = [NSNumber numberWithUnsignedInt:NSNotFound];
		closedMatchingSubjectDict = [NSDictionary dictionaryWithObjectsAndKeys:closestMatchingSubjectIndex, TSK_KEY_SUBJECT_INDEX, nil];
	}
	return closedMatchingSubjectDict;	
}

@end
