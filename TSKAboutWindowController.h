//
//  TSKAboutWindowController.h
//  Taskation
//
//  Created by Lyndsey on 4/1/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TSKAboutWindowController : NSWindowController {
	IBOutlet NSTextField* versionTextField;
	IBOutlet NSTextField* registeredUserTextLabel;
	IBOutlet NSTextField* registeredUserTextField;
}

@end
