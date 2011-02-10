#import "CapturedAppDelegate.h"
#import "Utilities.h"
#import "DirEvents.h"
#import "EventsController.h"

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
    
//    [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyRegular];

    welcomeWindowController = [[WelcomeWindowController alloc] init];

    if ([NSBundle loadNibNamed:@"WelcomeWindow" owner:welcomeWindowController]) {
        [[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
        [welcomeWindowController makeKeyAndOrderFront: self];
        NSLog(@"Loading Nib for Welcome!");
    }

    
}

- (void)initEventsController {
	eventsController = [[EventsController alloc] init]; //This used to be autorelease, but I would get a crash. So now I think I need to do something to release the memory
	[eventsController setupEventListener];
	
}

- (void)dealloc {
	[eventsController release], eventsController = nil;   
    [super dealloc];
}

- (void)statusProcessing {
	[statusMenuController setStatusProcessing];
}

- (void)uploadSuccess: (NSString *) url {
	NSLog(@"Upload succeeded: %@", url);
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
@end