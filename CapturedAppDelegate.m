#import "CapturedAppDelegate.h"
#import "Utilities.h"
#import "DirEvents.h"
#import "EventsController.h"
#import "DDHotKeyCenter.h"

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
    
    [self registerGlobalHotKey];
            
//    [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyRegular];
    
    if ([self isFirstRun])
    {
        [self showWelcomeWindow];
    }
    
    [self showAnnotateImageWindow];

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
    AnnotatedImageController* controller = [[AnnotatedImageController alloc] 
                                            initWithWindowNibName:@"AnnotatedImage"];
    [[controller window] makeKeyAndOrderFront:self];
    NSImage * image = [[NSImage alloc] initWithContentsOfFile:file]; 
    [controller setImage: image];
    
    //    AnnotatedImageController* controller = [[AnnotatedImageController alloc] initWithWindowNibName:@"AnnotatedImage"];
    //    
    //    if ([NSBundle loadNibNamed:@"AnnotatedImage" owner: controller]) {
    //        [[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
    //        NSImage * image = [[NSImage alloc] initWithContentsOfFile:@"/Users/csexton/test.tiff"]; 
    //        [controller setImage: image];
    //    }
  
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

- (void) hotkeyWithEvent:(NSEvent *)hkEvent {
    //NSLog(@"Firing -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	//NSLog(@"Hotkey event: %@", hkEvent);
    [self takeScreenCaptureAction:nil];
}

- (void) hotkeyAnnotateWithEvent:(NSEvent *)hkEvent {
    //NSLog(@"Firing -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	//NSLog(@"Hotkey event: %@", hkEvent);
    [self takeAnnotatedScreenCaptureAction:nil];
}

- (void) registerGlobalHotKey
{
    DDHotKeyCenter * c = [[DDHotKeyCenter alloc] init];
    // 
    // The keycode was found in 
    // /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
    // 
    if (![c registerHotKeyWithKeyCode:/*kVK_ANSI_5*/0x17 modifierFlags:(NSShiftKeyMask|NSCommandKeyMask) target:self action:@selector(hotkeyWithEvent:) object:nil]) {
        NSLog(@"Unable to register global keyboard shortcut");
    } else {
        NSLog(@"Registered global keyboard shortcut for Shift-Command-5");
    }
    
    if (![c registerHotKeyWithKeyCode:/*kVK_ANSI_6*/0x16 modifierFlags:(NSShiftKeyMask|NSCommandKeyMask) target:self action:@selector(hotkeyAnnotateWithEvent:) object:nil]) {
        NSLog(@"Unable to register global keyboard shortcut");
    } else {
        NSLog(@"Registered global keyboard shortcut for Shift-Command-6");
    }
    
    [c release];
}
@end