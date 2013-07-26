//
//  TSKReportWindow.m
//  Taskation
//
//  Created by Lyndsey on 3/25/09.
//  Copyright 2009 Lyndsey D. Ferguson. All rights reserved.
//

#import "TSKReportWindow.h"
#import "TSKReportWindowController.h"

@implementation TSKReportWindow

#if 0

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    SEL theAction = [anItem action];
	
    if (theAction == @selector(copy:))
    {
        if ( true )
        {
            return YES;
        }
        return NO;
    } else if (theAction == @selector(paste:))
    {
        if ( true )
        {
            return YES;
        }
        return NO;
    } else
	/* check for other relevant actions ... */
	
	// subclass of NSDocument, so invoke super's implementation
	return [super validateUserInterfaceItem:anItem];
}
#endif // 0
// ----------------------------------------------------------------------------

- (IBAction)runPageLayout:(id)sender
{
	NSPrintInfo* printInfo = [NSPrintInfo sharedPrintInfo];
	NSRect savedPageRect = [printInfo imageablePageBounds];
	
	[NSApp runPageLayout:sender];
	
	NSRect selectedPageRect = [printInfo imageablePageBounds];

	if (!NSEqualRects(savedPageRect, selectedPageRect)) {
		TSKReportWindowController* controller = (TSKReportWindowController*) [self windowController];
		[controller pageSizeChanged];
	}
}

@end
