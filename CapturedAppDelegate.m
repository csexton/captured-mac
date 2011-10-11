#import "CapturedAppDelegate.h"
#import "Utilities.h"
#import "DirEvents.h"
#import "EventsController.h"

#import "PreferencesController.h"
#import "AnnotatedImageController.h"


@implementation CapturedAppDelegate

@synthesize statusMenuController;
@synthesize welcomeWindowController;
@synthesize window;


-(id)init {
    self = [super init];
    if ( self ) {
		uploadsEnabled = YES;
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
        hotKeyCenter = [[DDHotKeyCenter alloc] init];
        
        annotatedWindows = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[self initEventsController];
	
	// XXX - Should this be a user option?
	//     - This means the main menu will not appear
	//     - It also means we can't drag and drop to the dock icon (which we don't do. Yet...)
	if (NO) {
		ProcessSerialNumber psn = { 0, kCurrentProcess };
		TransformProcessType(&psn, kProcessTransformToForegroundApplication);
	}
    
    [self registerGlobalHotKeys];
            
//    [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyRegular];
    
    if ([self isFirstRun])
    {
        [self showWelcomeWindow];
    }
    
//    [self showAnnotateImageWindow];

}

- (BOOL)isFirstRun {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL ret = [defaults boolForKey:@"FirstRun"];
    [defaults setValue:@"NO" forKey:@"FirstRun"]; // Go ahead and set this for next time
    return ret;
}

- (void)showWelcomeWindow {
    welcomeWindowController = [[WelcomeWindowController alloc] init];
    if ([NSBundle loadNibNamed:@"WelcomeWindow" owner:welcomeWindowController]) {
        [[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
    }
}
- (void)showAnnotateImageWindowWithFile: (NSString*) file {
    AnnotatedImageController* controller = [[AnnotatedImageController alloc] initWithWindowNibName:@"AnnotatedImage"];
    NSImage * image = [[NSImage alloc] initWithContentsOfFile:file]; 
    if ([image isValid]) {
        [controller setImageAndShowWindow: image]; 
        [annotatedWindows addObject:controller];
    }
    [image release];
    [controller release];
}

- (void)removeAnnotatedWindow: (id) w {
    [annotatedWindows removeObjectIdenticalTo:w];
}

- (void)showAnnotateImageWindow {
    [self showAnnotateImageWindowWithFile:@"/Users/csexton/test.tiff"];
}

- (void)initEventsController {
	eventsController = [[EventsController alloc] init]; //This used to be autorelease, but I would get a crash. So now I think I need to do something to release the memory
	[eventsController setupEventListener];
}

- (void)processFileEvent: (NSString *)path {
    [eventsController processFile: path];
}

- (void)dealloc {
	[eventsController release];
    eventsController = (EventsController*)nil;   
    [super dealloc];
}

- (void)statusProcessing {
	[statusMenuController setStatusProcessing];
}

- (void)uploadSuccess: (NSDictionary *) dict {
    NSString *url = [dict valueForKey:@"ImageURL"];
	NSLog(@"Upload succeeded: %@", url);
	[statusMenuController setStatusSuccess: dict];
}

- (void)uploadFailure {
	NSLog(@"Upload Failed.");
	[statusMenuController setStatusFailure];
	[statusMenuController performSelector: @selector(setStatusNormal) withObject: nil afterDelay: 5.0];
}

- (BOOL)uploadsEnabled {
	//NSLog(@"The value of the bool is %@\n", (uploadsEnabled ? @"YES" : @"NO"));
	return uploadsEnabled;
}
- (void)setUploadsEnabled: (BOOL)enabled {
    [PreferencesController sharedWillChangeValueForKey:@"uploadsEnabled"];

	if (enabled) {
		[statusMenuController setStatusNormal];
	} else {
		[statusMenuController setStatusDisabled];
	}
	uploadsEnabled = enabled;
    [PreferencesController sharedDidChangeValueForKey:@"uploadsEnabled"];
}

-(IBAction) takeScreenCaptureAction:(id) sender
{
	NSString *path = [Utilities invokeScreenCapture: @"-i"];
	[eventsController processFile: path];
}

-(IBAction) takeAnnotatedScreenCaptureAction:(id) sender
{
	NSString *path = [Utilities invokeScreenCapture: @"-i"];
    [self showAnnotateImageWindowWithFile:path];
}

-(IBAction) takeScreenCaptureWindowAction:(id) sender
{	
	NSString *path = [Utilities invokeScreenCapture: @"-w"];
	[eventsController processFile: path];
}

-(IBAction) showPreferencesWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps: YES];
	//[window makeKeyAndOrderFront:self];
    [[PreferencesController sharedPrefsWindowController] showWindow:nil];
	(void)sender;
}

-(IBAction) toggleStatusMenuItem:(id)sender
{
    [statusMenuController toggleStatusMenuItem:sender];
}

- (BOOL)startAtLogin
{
    return [Utilities willStartAtLogin:[Utilities appURL]];
}

- (void)setStartAtLogin:(BOOL)enabled
{
    [statusMenuController willChangeValueForKey:@"startAtLogin"];
    [PreferencesController sharedWillChangeValueForKey:@"startAtLogin"];
    [Utilities setStartAtLogin:[Utilities appURL] enabled:enabled];
    [PreferencesController sharedDidChangeValueForKey:@"startAtLogin"];
    [statusMenuController didChangeValueForKey:@"startAtLogin"];
}

- (void) primaryHotkeyWithEvent:(NSEvent *)hkEvent {
    //NSLog(@"Firing -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	//NSLog(@"Hotkey event: %@", hkEvent);
    [self takeScreenCaptureAction:nil];
}

- (void) annotateHotkeyWithEvent:(NSEvent *)hkEvent {
    //NSLog(@"Firing -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	//NSLog(@"Hotkey event: %@", hkEvent);
    [self takeAnnotatedScreenCaptureAction:nil];
}

- (BOOL) registerPrimaryHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags {
    [hotKeyCenter unregisterHotKeysWithTarget:self action:@selector(primaryHotkeyWithEvent:)];
    if ( [hotKeyCenter registerHotKeyWithKeyCode:keyCode 
                                   modifierFlags:flags 
                                          target:self 
                                          action:@selector(primaryHotkeyWithEvent:) 
                                          object:nil] ){
        
        // Save the new combo to defaults
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:keyCode forKey:@"KeybindingPrimaryCode"];
        [defaults setInteger:flags forKey:@"KeybindingPrimaryFlags"];
        return YES;
    } else {
        // Attempt to re-register the original keybindings
        [self registerGlobalHotKeys];
        // Then say we failed
        return NO;
    }
}
- (BOOL) registerAnnotateHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags {
    
    [hotKeyCenter unregisterHotKeysWithTarget:self action:@selector(annotateHotkeyWithEvent:)];
    if ( [hotKeyCenter registerHotKeyWithKeyCode:keyCode 
                                   modifierFlags:flags 
                                          target:self 
                                          action:@selector(annotateHotkeyWithEvent:) 
                                          object:nil] ){
        
        // Save the new combo to defaults
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:keyCode forKey:@"KeybindingAnnotateCode"];
        [defaults setInteger:flags forKey:@"KeybindingAnnotateFlags"];
        return YES;
    } else {
        // Attempt to re-register the original keybindings
        [self registerGlobalHotKeys];
        // Then say we failed
        return NO;
    }
}

- (void) registerGlobalHotKeys {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSInteger pKeyCode = [defaults integerForKey:@"KeybindingPrimaryCode"];
	NSInteger pModifierFlags = [defaults integerForKey:@"KeybindingPrimaryFlags"];
    NSInteger aKeyCode = [defaults integerForKey:@"KeybindingAnnotateCode"];
	NSInteger aModifierFlags = [defaults integerForKey:@"KeybindingAnnotateFlags"];
    
    // 
    // The keycode was found in 
    // /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
    // 
    if (![self registerPrimaryHotKeyWithKeyCode:pKeyCode modifierFlags:pModifierFlags]) {
        NSLog(@"Unable to register global keyboard shortcut");
    }
    
    if (![self registerAnnotateHotKeyWithKeyCode:aKeyCode modifierFlags:aModifierFlags]) {
        NSLog(@"Unable to register global keyboard shortcut");
    }
    
    // This is how I got the number to store in Defaults.plist
    //NSLog(@"CmdShift: %i", (NSShiftKeyMask|NSCommandKeyMask));

}

- (DDHotKeyCenter*) getHotKeyCenter
{
    return hotKeyCenter;
}
@end