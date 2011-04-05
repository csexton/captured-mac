
#import "PreferencesController.h"
#import "SFTPUploader.h"
#import "CloudUploader.h"
#import "EMKeychainItem.h"
#import "OAuthController.h"

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

+ (NSString *)nibName
{
   return @"Preferences";
}


- (void) dealloc {
	[super dealloc];
}

-(void)awakeFromNib{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	[self.window setContentSize:[generalPreferenceView frame].size];
	[[self.window contentView] addSubview:generalPreferenceView];
	[bar setSelectedItemIdentifier:@"General"];
	[self.window center];
        
	NSString * type = [defaults stringForKey:@"UploadType"];
    
    [uploadType selectItemWithObjectValue:type];
    [self selectUploaderViewWithType:type];
}


-(NSView *)viewForTag:(int)tag {
    NSView *view = nil;
	switch(tag) {
		case 0: default: view = generalPreferenceView; break;
		case 1: view = advancedPreferenceView; break;
		case 2: view = colorsPreferenceView; break;
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
    else if ([type isEqualToString: @"Picassa"]) {
        [uploaderBox setContentView:picassaPreferences];
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
    
    // This works, but I want it ot be modal 
    OAuthController* ctl = [[OAuthController alloc] init];
    [ctl showWindow:nil];

       
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
    CloudUploader *s = [[CloudUploader alloc] init];
    [self runTestConnection:s textField: s3TestLabel];
}

-(void) runTestConnection: (id)uploader textField: (NSTextField *)textFeild {
    NSString* ret = [uploader testConnection];
	[textFeild performSelectorOnMainThread:@selector(setStringValue:) withObject:ret waitUntilDone:YES];    
}

////// SFTP Settings Binding Methods ////////////////////////////////////////////////////

// Method to enable running the test in the background thread
-(void) runSFTPTestConnecton: (id) sender{
    SFTPUploader *s = [[SFTPUploader alloc] init];
    [self runTestConnection:s textField: sftpTestLabel];
}

-(IBAction) testS3Connection:(id) sender{
    [s3TestLabel setHidden:NO];
    [s3TestLabel setStringValue: @"Testing..."];
    [self performSelectorInBackground:@selector(runS3TestConnecton:) withObject:sender];
}


-(NSString *) sftpPassword {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* username = [defaults stringForKey:@"SFTPUser"];
    
    //Grab the keychain item.
    //    EMInternetKeychainItem *keychainItem = [EMInternetKeychainItem internetKeychainItemForServer:host withUsername:username path:@"" port:22 protocol:kSecProtocolTypeFTP];
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured SFTP" withUsername:username];
    
    if (keychainItem) {
        return keychainItem.password;
    } else {
        return @"";
    }
}
-(void) setSftpPassword:(NSString *)password {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* username = [defaults stringForKey:@"SFTPUser"];
    //    [EMInternetKeychainItem addInternetKeychainItemForServer:host 
    //                                                withUsername:username
    //                                                    password:str
    //                                                        path:@"" 
    //                                                        port:22 
    //                                                    protocol:'sftp'];
    
    // See if there is an existing keychain item
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured SFTP" withUsername:username];
    
    if (keychainItem) {
        // Update the password
        if (password) {
            keychainItem.password = password;
        }
    } else {
        // If we didn't find an item, lets create one
        keychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"Captured SFTP" withUsername:username password:password];
    }
}

-(NSString *) sftpUser { 
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"SFTPUser"];
}
-(void) setSftpUser:(NSString *)username {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *oldUsername = [defaults stringForKey:@"SFTPUser"];
    [defaults setValue:username forKey:@"SFTPUser"]; 
    
    // Update the username in the keychain
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured SFTP" withUsername:oldUsername];
    if (keychainItem) {
        keychainItem.username = username;
    }
}

////// Picassa Settings Binding Methods ////////////////////////////////////////////////////

-(void) runPicassaTestConnecton: (id) sender{
    SFTPUploader *s = [[SFTPUploader alloc] init];
    [self runTestConnection:s textField: sftpTestLabel];
}

-(IBAction) testPicassaConnection:(id) sender{
    [s3TestLabel setHidden:NO];
    [s3TestLabel setStringValue: @"Testing..."];
    [self performSelectorInBackground:@selector(runPicassaTestConnecton:) withObject:sender];
}

-(NSString *) picassaPassword {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* username = [defaults stringForKey:@"PicassaUser"];
    
    //Grab the keychain item.
    //    EMInternetKeychainItem *keychainItem = [EMInternetKeychainItem internetKeychainItemForServer:host withUsername:username path:@"" port:22 protocol:kSecProtocolTypeFTP];
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured Picassa" withUsername:username];
    
    if (keychainItem) {
        return keychainItem.password;
    } else {
        return @"";
    }
}
-(void) setPicassaPassword:(NSString *)password {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* username = [defaults stringForKey:@"PicassaUser"];
    // See if there is an existing keychain item
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured Picassa" withUsername:username];
    
    if (keychainItem) {
        // Update the password
        if (password) {
            keychainItem.password = password;
        }
    } else {
        // If we didn't find an item, lets create one
        keychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"Captured Picassa" withUsername:username password:password];
    }
}

-(NSString *) picassaUser {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"PicassaUser"];
}
-(void) setPicassaUser:(NSString *)username {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *oldUsername = [defaults stringForKey:@"PicassaUser"];
    [defaults setValue:username forKey:@"PicassaUser"];
    
    // Update the username in the keychain
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured Picassa" withUsername:oldUsername];
    if (keychainItem) {
        keychainItem.username = username;
    }
}
@end

