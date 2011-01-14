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
	
	// XXX
	// If I call it here I get a bad exec when the callback tries the delegate	
	EventsController *eventsController = [[[EventsController alloc] init] autorelease];
	[eventsController setupEventListener];
	

}

@end