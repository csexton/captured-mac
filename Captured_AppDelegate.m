#import "Captured_AppDelegate.h"
#import "SCEvents.h"
#import "Controller.h"

@implementation Captured_AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	

	[self initEventsController];
	
}

- (void)initEventsController {
	// Seems that a crash occurs if you try to set the menu title from a thread other than the main thread.
	if ([NSThread isMainThread])
	{
		Controller *eventsController = [[[Controller alloc] init] autorelease];
		[eventsController setupEventListener];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(initEventsController:) waitUntilDone:YES];
	}

}

@end