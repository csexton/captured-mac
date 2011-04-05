
#import <Cocoa/Cocoa.h>
#import "CapturedAppDelegate.h"

@interface PreferencesController : NSWindowController <NSToolbarDelegate> {

	IBOutlet NSToolbar *bar;
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *colorsPreferenceView;
	IBOutlet NSView *aboutPreferenceView;
	IBOutlet NSView *advancedPreferenceView;
    
    IBOutlet NSWindow *window;
    IBOutlet NSBox *uploaderBox;
    IBOutlet NSComboBox *uploadType;

    IBOutlet NSView *sftpPreferences;
    IBOutlet NSView *s3Preferences;
    IBOutlet NSView *imgurPreferences;
    IBOutlet NSView *dropboxPreferences;
    IBOutlet NSView *picassaPreferences;

    
    IBOutlet NSTextField *sftpTestLabel;
    IBOutlet NSTextField *s3TestLabel;
    IBOutlet NSTextField *imgurTestLabel;
    
    IBOutlet NSButtonCell *startAtLoginCheckBox;
    
    IBOutlet NSPanel *linkDropboxPanel; // XXX
    
    
    	
	int currentViewTag;
	
}

@property BOOL startAtLogin;
@property BOOL uploadsEnabled;
@property (assign) NSString * sftpPassword;
@property (assign) NSString * sftpUser;
@property (assign) NSString * picassaPassword;
@property (assign) NSString * picassaUser;


+ (PreferencesController *)sharedPrefsWindowController;
+ (void)sharedWillChangeValueForKey: (NSString *)key;
+ (void)sharedDidChangeValueForKey: (NSString *)key;

+ (NSString *)nibName;
-(NSView *)viewForTag:(int)tag;
-(IBAction)switchView:(id)sender;
-(NSRect)newFrameForNewContentView:(NSView *)view;

-(IBAction) selectUploader:(id) sender;
-(void) selectUploaderViewWithType: (NSString *) type;
-(IBAction) openHomepage:(id) sender;
-(IBAction) openBitlyPage:(id) sender;

-(IBAction) testSFTPConnection:(id) sender;
-(IBAction) testS3Connection:(id) sender;
-(IBAction) linkDropbox:(id) sender;

-(void) runTestConnection: (id)uploader textField: (NSTextField *)textFeild;

@end
