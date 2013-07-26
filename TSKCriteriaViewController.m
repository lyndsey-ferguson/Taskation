#import "TSKCriteriaViewController.h"

const CGFloat TSKCritieriaViewDefaultHeight = 20.0;

@implementation TSKCriteriaViewController

- (void)viewDidLoad
{
	NSLog(@"%@ viewDidLoad", self);
}

- (CGFloat)showCriteriaInContentView:(NSView*)contentView
{
	NSRect contentRect = [contentView frame];
	[contentView addSubview:[self view]];
	
	[[self view] setFrame:NSMakeRect(0, contentRect.size.height - TSKCritieriaViewDefaultHeight, contentRect.size.width, TSKCritieriaViewDefaultHeight)];
	[[self view] setHidden:NO];
	
	return [[self view] frame].size.height;
}

- (CGFloat)hideCriteriaInContentView
{
	[[self view] setHidden:YES];
	return [[self view] frame].size.height;
}

@end
