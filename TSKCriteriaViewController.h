#import <Cocoa/Cocoa.h>

@interface TSKCriteriaViewController : NSViewController {
	IBOutlet NSTableView* tableView;
}

- (void)viewDidLoad;
- (CGFloat)showCriteriaInContentView:(NSView*)contentView;
- (CGFloat)hideCriteriaInContentView;
@end
