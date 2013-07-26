//
//  TSKDocReportController.m
//  Taskation
//
//  Created by Lyndsey on 12/20/08.
//  Copyright 2008 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKDocWindowController.h"
#import "TSKReportWindowController.h"

@implementation TSKDocWindowController (Reports)

- (void)generateReport:(NSNotification*)notification
{	
	NSArray* activitiesData = nil;
	
	if (isCriteriaVisible) {
		activitiesData = [activities filteredArrayUsingPredicate:[predicateEditor predicate]];
	}
	else {
		activitiesData = activities;
	}
	TSKReportWindowController* reportController = [[TSKReportWindowController alloc] initWithActivitiesData:activitiesData]; 
	[reportController showWindow:self];
}


@end
