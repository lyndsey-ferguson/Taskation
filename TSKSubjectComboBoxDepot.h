//
//  TSKSubjectComboBoxDepot.h
//  Taskation
//
//  Created by Lyndsey on 1/18/09.
//  Copyright 2009 Lyndsey D. Ferguson All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKDefinitions;

@interface TSKSubjectComboBoxDepot : NSObject {
	NSComboBox* actionComboBox;
	TSKDefinitions* activityDefinitions;
}

- (id)initWithDefinitions:(TSKDefinitions*)theDefinitions
				andActionComboBox:(NSComboBox*)comboBox;
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index;
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox;
- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString;
- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString;

@end
