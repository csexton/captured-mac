#import "CapturedAppDelegate.h"
#import "SCEvents.h"
#import "EventsController.h"

@implementation CapturedAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[self initEventsController];
}

- (void)initEventsController {
	eventsController = [[EventsController alloc] init]; //This used to be autorelease, but I would get a crash. So now I think I need to do something to release the memory
	[eventsController setupEventListener];
}

- (void)dealloc {
	[eventsController release], eventsController = nil;   
    [super dealloc];
}

@end