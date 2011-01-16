#import "CapturedAppDelegate.h"
#import "Utilities.h"
#import "DirEvents.h"
#import "EventsController.h"

@implementation CapturedAppDelegate

@synthesize window;
@synthesize statusMenuController;
//@synthesize uploadsEnabled;

-(id)init {
    if ( self = [super init] ) {
		uploadsEnabled = YES;
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	

		
	// Insert code here to initialize your application 
	[self initEventsController];
	
	// XXX  -  DO THIS!!!
	// http://stackoverflow.com/questions/620841/how-to-hide-the-dock-icon
	if (NO) {
		ProcessSerialNumber psn = { 0, kCurrentProcess };
		TransformProcessType(&psn, kProcessTransformToForegroundApplication);
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

+ (void)statusProcessing {
	[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] setStatusProcessing];
}
- (void)setStatusProcessing {
	[statusMenuController setStatusProcessing];
}

//+ (void)statusNormal {
//	[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] setStatusNormal];
//}
//- (void)setStatusNormal {
//	[statusMenuController setStatusNormal];
//}

+ (void)uploadSuccess: (NSString *) url {
	[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] setUploadSuccess:url];
}
- (void)setUploadSuccess: (NSString *) url {
	[statusMenuController setStatusSuccess];
	[Utilities copyToPasteboard:url];
	[statusMenuController performSelector: @selector(setStatusNormal) withObject: nil afterDelay: 5.0];


}

+ (void)uploadFailure {
	[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] setUploadFailure];
}
- (void)setUploadFailure {
	[statusMenuController setStatusFailure];
	[statusMenuController performSelector: @selector(setStatusNormal) withObject: nil afterDelay: 5.0];
}


- (BOOL)uploadsEnabled {
	NSLog(@"The value of the bool is %@\n", (uploadsEnabled ? @"YES" : @"NO"));
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
 





@end