
#import "Preferences.h"
static Preferences *_sharedPrefsWindowController = nil;

@implementation Preferences

#pragma mark -
#pragma mark Class Methods
+ (Preferences *)sharedPrefsWindowController
{
	if (!_sharedPrefsWindowController) {
		_sharedPrefsWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	}
	return _sharedPrefsWindowController;
}


+ (NSString *)nibName
{
   return @"Preferences";
}


- (void) dealloc {
	[super dealloc];
}

-(void)awakeFromNib{
	[self.window setContentSize:[generalPreferenceView frame].size];
	[[self.window contentView] addSubview:generalPreferenceView];
	[bar setSelectedItemIdentifier:@"General"];
	[self.window center];
        
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
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
		case 3: view = updatesPreferenceView; break;
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
	return [(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadsEnabled];
}
- (void)setUploadsEnabled: (BOOL)enabled {
    [(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] setUploadsEnabled: enabled];
}
- (BOOL)startAtLogin {
	return [(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] startAtLogin];
}
- (void)setStartAtLogin:(BOOL)enabled {
    [(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] setStartAtLogin: enabled];
}


-(IBAction) selectUploader:(id) sender
{
    NSComboBox *combo = (NSComboBox*)sender;
    NSString* type = [combo stringValue];
    //NSView *currentView = [[uploaderBox subviews] objectAtIndex:0];
    
    //Deletes all subviews
    //[uploaderBox setSubviews:[NSArray array]];
    
    [self selectUploaderViewWithType: type];
    
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
    else if ([type isEqualToString: @"Amazon S3"]) {
        [uploaderBox setContentView:s3Preferences];
    }
    else if ([type isEqualToString: @"Dropbox"]) {
        [uploaderBox setContentView:dropboxPreferences];
    }
    else {
        [uploaderBox setContentView:imgurPreferences];
    }
}


@end
