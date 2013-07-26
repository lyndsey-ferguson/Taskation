//
//  TSKDocDefinitionsWindowController.h
//  Taskation
//
//  Created by Lyndsey on 4/1/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TSKDefinitions;
@class TSKDefinitionsViewController;

@interface TSKDocDefinitionsWindowController : NSWindowController {
	TSKDefinitionsViewController* definitionsViewController;
	IBOutlet NSView* definitionsSuperview;
}

- (id)initWithDefinitions:(TSKDefinitions*)theDefinitions;
- (IBAction)okButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@end
