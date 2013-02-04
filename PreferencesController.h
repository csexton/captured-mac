
#import <Cocoa/Cocoa.h>
#import "CapturedAppDelegate.h"
#import "DropboxPreferencesController.h"
#import "SRRecorderControl.h"


@interface PreferencesController : NSWindowController <NSToolbarDelegate, NSWindowDelegate> {

	IBOutlet NSToolbar *bar;
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *keybindingsPreferenceView;
	IBOutlet NSView *aboutPreferenceView;
	IBOutlet NSView *advancedPreferenceView;

    IBOutlet NSWindow *window;
    IBOutlet NSBox *uploaderBox;
    IBOutlet NSComboBox *uploadType;

    IBOutlet NSView *sftpPreferences;
    IBOutlet NSView *s3Preferences;
    IBOutlet NSView *dropboxLinkedPreferences;
    NSView *dropboxPreferences;
    NSView *imgurPreferences;
    DropboxPreferencesController *dropboxPreferencesController;

    IBOutlet NSView *picasaPreferences;

    IBOutlet NSTextField *sftpTestLabel;
    IBOutlet NSTextField *s3TestLabel;
    IBOutlet NSTextField *imgurTestLabel;
    IBOutlet NSTextField *picasaTestLabel;
    
    IBOutlet NSTextField *sftpPublicKeyField;
    IBOutlet NSTextField *sftpPrivateKeyField;

    
    IBOutlet NSButtonCell *startAtLoginCheckBox;
    IBOutlet NSButton *showStatusMenuItemCheckBox;
    
    IBOutlet SRRecorderControl *primaryShortcutRecorder;
    IBOutlet SRRecorderControl *annotatedShortcutRecorder;

    IBOutlet NSPanel *myCustomDialog; // XXX

	int currentViewTag;
}

@property BOOL startAtLogin;
@property BOOL uploadsEnabled;
@property (assign) NSString * sftpPassword;
@property (assign) NSString * picasaPassword;


+ (PreferencesController *)sharedPrefsWindowController;
+ (void)sharedWillChangeValueForKey: (NSString *)key;
+ (void)sharedDidChangeValueForKey: (NSString *)key;

- (void)windowDidBecomeKey:(NSNotification *)notification;
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
-(IBAction) toggleStatusMenuItem:(id) sender;

-(IBAction) openPublicKey:(id) sender;


-(void) runTestConnection: (id)uploader textField: (NSTextField *)textFeild;

@end
