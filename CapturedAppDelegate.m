#import "CapturedAppDelegate.h"
#import "Utilities.h"
#import "DirEvents.h"
#import "EventsController.h"

@implementation CapturedAppDelegate

@synthesize window;
@synthesize statusMenuController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[self initEventsController];
	
	// XXX  -  DO THIS!!!
	// http://stackoverflow.com/questions/620841/how-to-hide-the-dock-icon
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





@end