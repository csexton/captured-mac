
#import <Cocoa/Cocoa.h>

@interface Preferences : NSWindowController <NSToolbarDelegate> {

	IBOutlet NSToolbar *bar;
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *colorsPreferenceView;
	IBOutlet NSView *updatesPreferenceView;
	IBOutlet NSView *advancedPreferenceView;
	
	int currentViewTag;
	
}

+ (Preferences *)sharedPrefsWindowController;
+ (NSString *)nibName;
-(NSView *)viewForTag:(int)tag;
-(IBAction)switchView:(id)sender;
-(NSRect)newFrameForNewContentView:(NSView *)view;
@end
