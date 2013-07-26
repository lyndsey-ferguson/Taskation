//
//  TSKActionSubjectManager.h
//  Taskation
//
//  Created by Lyndsey on 1/17/09.
//  Copyright 2009 Lyndsey D. Ferguson All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* TSK_ACTION_ALL_SUBJECTS;
extern NSString* TSK_TABLEVIEW_EMPTY_STRING;

@class NSString;

/**
 @class TSKActionSubjectManager
 
 Manages the actions and subjects that are used to create activities that the user can record.
 
 The actions instance variable is an array of NSDictionaries.  Each NSDictionary is composed of:
	- a action name (NSString*) accessed by using the TSK_KEY_NAME.
	- an array (NSArray*) of subject indexes (NSNumber*) accessed by using the TSK_KEY_SUBJECTS.

 The subjects instance variable is an array of NSStrings.
 
 */
@interface TSKDefinitions : NSObject {
	NSMutableDictionary* actions; 
	NSMutableDictionary* subjects;
}

@property (readonly) NSDictionary* actions;
@property (readonly) NSDictionary* subjects;

- (id)init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)initWithDefinitions:(TSKDefinitions*)originalDefinitions;
- (void)encodeWithCoder:(NSCoder *)aCoder;

#pragma mark -
#pragma mark Actions

/**
 @brief returns an action id for a new action string description. If the action already exists, returns its action id.
 */
- (NSString*)addAction:(NSString*)action;

/**
 @brief returns a string description for the given action id.
*/
- (NSString*)actionForActionID:(NSString*)anActionID;

/**
 @brief returns an action id for the given action string description. If there is no corresponding action, nil is returned.
 */
- (NSString*)actionIDForAction:(NSString*)action;

/**
 @brief returns the Nth action or an empty string if there is no such action.
 */
- (NSString*)actionAtIndex:(int)theIndex;

/**
 @brief returns the action id for the action at the given index.
 */
- (NSString*)actionIDForActionAtIndex:(int)theIndex;

/**
 @brief returns the index of the given action id.
 */
- (int)indexForActionID:(NSString*)actionID;

/**
 @brief sets the action string for the nth action.
 */
- (BOOL)setAction:(NSString*)theAction atIndex:(int)theIndex;

/**
 @brief removes the action at the given index.
 */
- (BOOL)removeActionAtIndex:(int)theIndex;

/**
 @brief returns the number of known actions.
 */
- (NSUInteger)actionCount;

/**
 @brief returns a NSDictionary, that contains the index (TSK_KEY_ACTION_INDEX:NSNumber*) and the action string (TSK_KEY_NAME:NSString*), that most closely matches the given partial action string.
 */
- (NSDictionary*)closestMatchingAction:(NSString*)aPartialActionString;

#pragma mark -
#pragma mark Subjects

/**
 @brief returns an subject id for a new subject string description. If the subject already exists, returns its subject id.
 @param subject the new subject description to add.
 */
- (NSString*)addSubject:(NSString*)subject;

/**
 @brief creates an association between the given subject and action.
 @return NO if either the subject index or the action index is invalid.
 */
- (BOOL)associateSubject:(NSString*)aSubjectID
			   withAction:(NSString*)anActionID;

/**
 @brief returns an array of NSDictionaries that contain the subject's ID and string description for the given action ID.
 */
- (NSArray*)subjectsForActionID:(NSString*)anActionID;

/**
 @brief returns a string description for the given subject index.
 */
- (NSString*)subjectForSubjectID:(NSString*)aSubjectID;

/**
 @brief returns a subject ID for the given subject string description. If there is no corresponding subject, nil is returned.
 */
- (NSString*)subjectIDForSubject:(NSString*)subject;

/**
 @brief returns the Nth subject or an empty string if there is no such subject for a given action. If anAction is nil, then returns the nth subject out of all of the subjects.
 */
- (NSString*)subjectAtIndex:(int)theIndex
			  forAction:(NSString*)anAction;

/**
 @brief sets the subject string for the nth subject for the associated action.
 */
- (BOOL)setSubject:(NSString*)aSubject
		   atIndex:(int)theIndex
	   forActionID:(NSString*)anActionID;

-  (int)indexOfSubjectID:(NSString*)aSubjectID forActionID:(NSString*)anActionID;

/**
 @brief removes the subject at the given index for the given action.
 */
- (BOOL)removeSubjectAtIndex:(int)theIndex
				 forActionID:(NSString*)anActionID;

/**
 @brief returns the number of known subjects for the given action. If anAction is nil, then returns a count for all subjects.
 */
- (NSUInteger)subjectCountForAction:(NSString*)anAction;

/**
 returns a NSDictionary, that contains the index (TSK_KEY_SUBJECT_INDEX:NSNumber*) and 
	the subject string (TSK_KEY_NAME:NSString*), that most closely matches the given 
	partial subject string for the subjects associated with the given action.
 */
- (NSDictionary*)closestMatchingSubject:(NSString*)aPartialSubjectString
							  forAction:(NSString*)anAction;

@end
