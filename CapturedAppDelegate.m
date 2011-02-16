#import "CapturedAppDelegate.h"
#import "Utilities.h"
#import "DirEvents.h"
#import "EventsController.h"
#import "DDHotKeyCenter.h"


@implementation CapturedAppDelegate


@synthesize window;
@synthesize statusMenuController;
@synthesize welcomeWindowController;


-(id)init {
    self = [super init];
    if ( self ) {
		uploadsEnabled = YES;
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
    
}

- (BOOL)isFirstRun {
    
    // This should probably be moved somewhere to a common instance of NSUserDefaults, but right now
	// I only need the one setting so this seems stupid simple
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys: @"YES",  @"FirstRun",	nil]];
    
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

- (void)initEventsController {
	eventsController = [[EventsController alloc] init]; //This used to be autorelease, but I would get a crash. So now I think I need to do something to release the memory
	[eventsController setupEventListener];
	
}

- (void)dealloc {
	[eventsController release];
    eventsController = (EventsController*)nil;   
    [super dealloc];
}

- (void)statusProcessing {
	[statusMenuController setStatusProcessing];
}

- (void)uploadSuccess: (ImgurURL *) url {
	NSLog(@"Upload succeeded: %@", url.imageURL);
	[statusMenuController setStatusSuccess: url];
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
	if (enabled) {
		[statusMenuController setStatusNormal];
	}
	else {
		[statusMenuController setStatusDisabled];
	}

	uploadsEnabled = enabled;
}

-(IBAction) takeScreenCaptureAction:(id) sender
{
	NSString *path = [Utilities invokeScreenCapture: @"-i"];
	[eventsController processFile: path];
}

-(IBAction) takeScreenCaptureWindowAction:(id) sender
{	
	NSString *path = [Utilities invokeScreenCapture: @"-w"];
	[eventsController processFile: path];
}

- (BOOL)startAtLogin
{
    return [Utilities willStartAtLogin:[Utilities appURL]];
}

- (void)setStartAtLogin:(BOOL)enabled
{
    [statusMenuController willChangeValueForKey:@"startAtLogin"];
    [Utilities setStartAtLogin:[Utilities appURL] enabled:enabled];
    [statusMenuController didChangeValueForKey:@"startAtLogin"];
}

- (void) hotkeyWithEvent:(NSEvent *)hkEvent {
    //NSLog(@"Firing -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	//NSLog(@"Hotkey event: %@", hkEvent);
    [self takeScreenCaptureAction:nil];
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
        //NSLog(@"Registered: %@", [c registeredHotKeys]);
    }
    [c release];
}
@end