//
//  TSKActionSubjectWindowController.h
//  Taskation
//
//  Created by Lyndsey on 1/26/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKDefinitionsViewController;

@interface TSKPrefsWindowController : NSWindowController {	
	TSKDefinitionsViewController* definitionsViewController;
	
	IBOutlet NSView* definitionsSuperview;
}

@end
