
#import "PreferencesController.h"
#import "SFTPUploader.h"
#import "CloudUploader.h"
#import "EMKeychainItem.h"
#import "DropboxPreferencesController.h"
#import "ImgurPreferencesController.h"


static PreferencesController *_sharedPrefsWindowController = nil;

@implementation PreferencesController

#pragma mark -
#pragma mark Class Methods
+ (PreferencesController *)sharedPrefsWindowController
{
	if (!_sharedPrefsWindowController) {
		_sharedPrefsWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	}
	return _sharedPrefsWindowController;
}

+ (void)sharedWillChangeValueForKey: (NSString *)key
{
	if (_sharedPrefsWindowController) {
        [_sharedPrefsWindowController willChangeValueForKey:key];
    } 
}
+ (void)sharedDidChangeValueForKey: (NSString *)key
{
	if (_sharedPrefsWindowController) {
        [_sharedPrefsWindowController didChangeValueForKey:key];
    } 
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [dropboxPreferencesController showApproprateView]; // Hacky hack
}

+ (NSString *)nibName
{
   return @"Preferences";
}


- (void) dealloc {
	[super dealloc];
}

-(void)awakeFromNib{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    dropboxPreferencesController = [[DropboxPreferencesController alloc] initWithNibName:@"DropboxPreferences" bundle:nil];
    dropboxPreferences = [dropboxPreferencesController view];
    imgurPreferences = [[[ImgurPreferencesController alloc] initWithNibName:@"ImgurPreferences" bundle:nil] view];

	[self.window setContentSize:[generalPreferenceView frame].size];
	[[self.window contentView] addSubview:generalPreferenceView];
	[bar setSelectedItemIdentifier:@"General"];
	[self.window center];
        
	NSString * type = [defaults stringForKey:@"UploadType"];
    
    [uploadType selectItemWithObjectValue:type];
    [self selectUploaderViewWithType:type];
    
    // Keybindings    
    NSInteger pKeyCode = [defaults integerForKey:@"KeybindingPrimaryCode"];
	NSInteger pModifierFlags = [defaults integerForKey:@"KeybindingPrimaryFlags"];
    NSInteger aKeyCode = [defaults integerForKey:@"KeybindingAnnotateCode"];
	NSInteger aModifierFlags = [defaults integerForKey:@"KeybindingAnnotateFlags"];
    [primaryShortcutRecorder setDelegate:self];
    [annotatedShortcutRecorder setDelegate:self];
    [primaryShortcutRecorder setKeyCombo:SRMakeKeyCombo(pKeyCode, pModifierFlags)];
    [annotatedShortcutRecorder setKeyCombo:SRMakeKeyCombo(aKeyCode, aModifierFlags)];
    
    // Uncheck "Show status item" if defaults says it is not set
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowStatusMenuItem"] boolValue]){
        [showStatusMenuItemCheckBox setState:NSOffState];
    } 
}


-(NSView *)viewForTag:(int)tag {
    NSView *view = nil;
	switch(tag) {
		case 0: default: view = generalPreferenceView; break;
		case 1: view = advancedPreferenceView; break;
		case 2: view = keybindingsPreferenceView; break;
		case 3: view = aboutPreferenceView; break;
	}
    return view;
}
-(NSRect)newFrameForNewContentView:(NSView *)view {
	
    NSRect newFrameRect = [self.window frameRectForContentRect:[view frame]];
    NSRect oldFrameRect = [self.window frame];
    NSSize newSize = newFrameRect.size;
    NSSize oldSize = oldFrameRect.size;    
    NSRect frame = [self.window frame];
    frame.size = newSize;
    frame.origin.y -= (newSize.height - oldSize.height);
    
    return frame;
}

-(IBAction)switchView:(id)sender {
	
	int tag = [sender tag];
	
	NSView *view = [self viewForTag:tag];
	NSView *previousView = [self viewForTag: currentViewTag];
	currentViewTag = tag;
	NSRect newFrame = [self newFrameForNewContentView:view];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.1];
	
	if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask)
	    [[NSAnimationContext currentContext] setDuration:1.0];
	
	[[[self.window contentView] animator] replaceSubview:previousView with:view];
	[[self.window animator] setFrame:newFrame display:YES];
	
	[NSAnimationContext endGrouping];
	
}


-(NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
	return [[toolbar items] valueForKey:@"itemIdentifier"];
}

- (BOOL)uploadsEnabled {
	return [AppDelegate uploadsEnabled];
}
- (void)setUploadsEnabled: (BOOL)enabled {
    [AppDelegate setUploadsEnabled: enabled];
}
- (BOOL)startAtLogin {
	return [AppDelegate startAtLogin];
}
- (void)setStartAtLogin:(BOOL)enabled {
    [AppDelegate setStartAtLogin: enabled];
}


-(IBAction) selectUploader:(id) sender{
    NSPopUpButtonCell *cell = [sender selectedCell];
    NSLog (@"Name of cell is %@", cell.title);

    [self selectUploaderViewWithType: cell.title];
}

-(void) selectUploaderViewWithType: (NSString *) type {
    
    [uploaderBox setTitle: [NSString stringWithFormat: @"%@ Settings", type]];
    
    if ([type isEqualToString: @"Imgur"]) {
        [uploaderBox setContentView:imgurPreferences];
    }
    else if ([type isEqualToString: @"SFTP"]) {
        [uploaderBox setContentView:sftpPreferences];
    }
    else if ([type isEqualToString: @"Amazon S3"]) {
        [uploaderBox setContentView:s3Preferences];
    }
    else if ([type isEqualToString: @"Dropbox"]) {
        [uploaderBox setContentView:dropboxPreferences];
    }
    else if ([type isEqualToString: @"Picasa"]) {
        [uploaderBox setContentView:picasaPreferences];
    }
    else {
        [uploaderBox setContentView:imgurPreferences];
    }
}

-(IBAction) openHomepage:(id) sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.codeography.com/captured"]];
}

-(IBAction) openBitlyPage:(id) sender{
    
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://bit.ly/a/account"]];
}

-(IBAction) testSFTPConnection:(id) sender{
    [sftpTestLabel setHidden:NO];
    [sftpTestLabel setStringValue: @"Testing..."];

    [self performSelectorInBackground:@selector(runSFTPTestConnecton:) withObject:sender];
}

////// Dropbox Settings Binding Methods ////////////////////////////////////////////////////
-(IBAction) linkDropbox: (id) sender{
    

    [uploaderBox setContentView:dropboxLinkedPreferences];

    
    
    // This works, but I want it ot be modal 
//    OAuthController* ctl = [[OAuthController alloc] init];
//    [ctl showWindow:nil];

       
//    //progressPanel is an IBOutlet to the NSPanel
//    if(!linkDropboxPanel)
//        [NSBundle loadNibNamed:@"OAuthWindow" owner:self];
//    
//    [NSApp beginSheet: linkDropboxPanel
//       modalForWindow: window
//        modalDelegate: nil
//       didEndSelector: nil
//          contextInfo: nil];
//    
//    //modalSession is an instance variable
//    NSModalSession modalSession = [NSApp beginModalSessionForWindow:linkDropboxPanel];
//        
//    [NSApp runModalSession:modalSession];
    
//----
//    NSWindow * win = [ctl window];
//    [NSApp runModalForWindow: [ctl window]];

    
}

////// S3 Settings Binding Methods ////////////////////////////////////////////////////

// Method to enable running the test in the background thread
-(void) runS3TestConnecton: (id) sender{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    CloudUploader *s = [[CloudUploader alloc] init];
    [self runTestConnection:s textField: s3TestLabel];
    [s release];
	[pool release];
}

-(void) runTestConnection: (id)uploader textField: (NSTextField *)textField {
    NSString* ret = [uploader testConnection];
    if (ret == nil) {
        [textField performSelectorOnMainThread:@selector(setStringValue:) withObject:@"Success!" waitUntilDone:YES];    

    } else {
        [textField performSelectorOnMainThread:@selector(setStringValue:) withObject:ret waitUntilDone:YES];    
    }
}

////// SFTP Settings Binding Methods ////////////////////////////////////////////////////

// Method to enable running the test in the background thread
-(void) runSFTPTestConnecton: (id) sender{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    SFTPUploader *s = [[SFTPUploader alloc] init];
    [self runTestConnection:s textField: sftpTestLabel];
	[pool release];
}

-(IBAction) testS3Connection:(id) sender{
    [s3TestLabel setHidden:NO];
    [s3TestLabel setStringValue: @"Testing..."];
    [self performSelectorInBackground:@selector(runS3TestConnecton:) withObject:sender];
}


-(NSString *) sftpPassword {
    //Grab the keychain item.
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured SFTP" withUsername:@""];
    
    if (keychainItem) {
        return keychainItem.password;
    } else {
        return @"";
    }
}
-(void) setSftpPassword:(NSString *)password {

    // See if there is an existing keychain item
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured SFTP" withUsername:@""];
    
    if (keychainItem) {
        // Update the password
        if (password) {
            keychainItem.password = password;
        } else {
            [keychainItem removeFromKeychain];
        }
    } else if (password) {
        // If we didn't find an item, lets create one
        keychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"Captured SFTP" withUsername:@"" password:password];
    }
}

-(IBAction) openPublicKey:(id)sender {
    NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"pub", @"PUB", nil];
    
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setExtensionHidden:YES];    
    [openDlg setFloatingPanel:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:YES];
    [openDlg setAllowedFileTypes:fileTypes];
        
    [openDlg setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@".ssh"]]];
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton ) {
        NSString* pubKeyFile = [[openDlg URL] path];
        //[sftpPublicKeyField setStringValue:pubKeyFile];
        NSString* privKeyFile = [pubKeyFile stringByReplacingOccurrencesOfString:@".pub"
                                                               withString:@""];
        //[sftpPrivateKeyField setStringValue:privKeyFile];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:pubKeyFile  forKey:@"SFTPPublicKeyFile"];
        [defaults setValue:privKeyFile forKey:@"SFTPPrivateKeyFile"];
        [defaults synchronize];


    }
}

////// Picasa Settings Binding Methods ////////////////////////////////////////////////////

-(void) runPicasaTestConnecton: (id) sender{
//	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//    PicasaUploader *s = [[PicasaUploader alloc] init];
//    [self runTestConnection:s textField: picasaTestLabel];
//    [s release];
//	[pool release];
}

-(IBAction) testPicasaConnection:(id) sender{
    [s3TestLabel setHidden:NO];
    [s3TestLabel setStringValue: @"Testing..."];
    [self performSelectorInBackground:@selector(runPicasaTestConnecton:) withObject:sender];
}

-(NSString *) picasaPassword {

    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured Picasa" withUsername:@""];
    
    if (keychainItem) {
        return keychainItem.password;
    } else {
        return @"";
    }
}
-(void) setPicasaPassword:(NSString *)password {
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured Picasa" withUsername:@""];
    if (keychainItem) {
        if (password) {
            keychainItem.password = password;
        } else {
            [keychainItem removeFromKeychain];
        }
    } else if (password) {
        // If we didn't find an item, lets create one
        keychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"Captured Picasa" withUsername:@"" password:password];
    }
}



- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
{
    BOOL isTaken = YES;

    if (aRecorder == annotatedShortcutRecorder) {
        isTaken = ![AppDelegate registerAnnotateHotKeyWithKeyCode: keyCode modifierFlags: flags];

    }
    if (aRecorder == primaryShortcutRecorder) {
        isTaken = ![AppDelegate registerPrimaryHotKeyWithKeyCode: keyCode modifierFlags: flags];
    }
    //	if (aRecorder == shortcutRecorder)
    //	{
    //		BOOL isTaken = NO;
    //		
    //		KeyCombo kc = [delegateDisallowRecorder keyCombo];
    //		
    //		if (kc.code == keyCode && kc.flags == flags) isTaken = YES;
    //		
    //		*aReason = [delegateDisallowReasonField stringValue];
    //		
    //		return isTaken;
    //	}
    //	
    
    
    return isTaken;
    
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
    // This is called after the above method when the user types in a code, however it is also called when the user clears
    // the shortcut -- so I just duplicated it. If you call set shortcut with nil code and flags it will be cleared. so 
    // this works to clear it out when the user deletes the shortcut.
    [self shortcutRecorder: aRecorder isKeyCode:newKeyCombo.code andFlagsTaken:newKeyCombo.flags reason:nil];

    //	if (aRecorder == shortcutRecorder)
    //	{
    //		[self toggleGlobalHotKey: aRecorder];
    //	}
}

-(IBAction) toggleStatusMenuItem:(id) sender {  
    [AppDelegate toggleStatusMenuItem: sender];
}






@end

