
#import <Cocoa/Cocoa.h>
#import "CapturedAppDelegate.h"

@interface Preferences : NSWindowController <NSToolbarDelegate> {

	IBOutlet NSToolbar *bar;
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *colorsPreferenceView;
	IBOutlet NSView *updatesPreferenceView;
	IBOutlet NSView *advancedPreferenceView;
    
    IBOutlet NSWindow *window;
    IBOutlet NSBox *uploaderBox;
    IBOutlet NSComboBox *uploadType;

    IBOutlet NSView *sftpPreferences;
    IBOutlet NSView *s3Preferences;
    IBOutlet NSView *imgurPreferences;
    IBOutlet NSView *dropboxPreferences;
    
    IBOutlet NSButtonCell *startAtLoginCheckBox;
    
    
    	
	int currentViewTag;
	
}

@property BOOL startAtLogin;
@property BOOL uploadsEnabled;


+ (Preferences *)sharedPrefsWindowController;
+ (void)sharedWillChangeValueForKey: (NSString *)key;
+ (void)sharedDidChangeValueForKey: (NSString *)key;

+ (NSString *)nibName;
-(NSView *)viewForTag:(int)tag;
-(IBAction)switchView:(id)sender;
-(NSRect)newFrameForNewContentView:(NSView *)view;

-(IBAction) selectUploader:(id) sender;
-(void) selectUploaderViewWithType: (NSString *) type;
@end
