/*
 *  $Id: Controller.m 46 2009-11-28 23:14:41Z stuart $
 *
 *  SCEvents
 *
 *  Copyright (c) 2009 Stuart Connolly
 *  http://stuconnolly.com/projects/source-code/
 *
 *  Permission is hereby granted, free of charge, to any person
 *  obtaining a copy of this software and associated documentation
 *  files (the "Software"), to deal in the Software without
 *  restriction, including without limitation the rights to use,
 *  copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following
 *  conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 * 
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 *  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 *  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 *  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *  OTHER DEALINGS IN THE SOFTWARE.
 */

#import "EventsController.h"
#import "Utilities.h"
#import "DirEvents.h"
#import "DirEvent.h"

@implementation EventsController

@synthesize screenCapturePrefix;
@synthesize screenCaptureDir;
@synthesize history;

/**
 * Sets up the event listener using SCEvents and sets its delegate to this controller.
 * The event stream is started by calling startWatchingPaths: while passing the paths
 * to be watched.
 */
- (void)setupEventListener
{
	// Load this into a member var so we don't have to read the plist every time the 
	// event gets fired	
	screenCapturePrefix = [Utilities screenCapturePrefix];
	screenCaptureDir = [Utilities screenCaptureDir];
	history = [[NSMutableSet alloc] init]; 

	
    DirEvents *events = [DirEvents sharedPathWatcher];
    
    [events setDelegate:self];
	    
	NSMutableArray *paths = [NSMutableArray arrayWithObject:screenCaptureDir];


	
	// Start receiving events
	[events startWatchingPaths:paths];
	
	events.ignoreEventsFromSubDirs = YES;

	// Display a description of the stream
	NSLog(@"%@", [events streamDescription]);	
}

/**
 * This is the only method to be implemented to conform to the SCEventListenerProtocol.
 * As this is only an example the event received is simply printed to the console.
 */
- (void)pathWatcher:(DirEvents *)pathWatcher eventOccurred:(DirEvent *)event
{
    //NSLog(@"%@", event);
	NSArray *list = [self findFilesWithPrefix:screenCapturePrefix inDir:screenCaptureDir];
	
	for (NSString *path in list) {
		NSLog(@" --- %@", path);
	}
}

- (NSArray *)findFilesWithPrefix: (NSString*)prefix inDir:(NSString*)basepath{
	
	NSMutableArray *list = [[NSMutableArray alloc] init]; 


	// Iterate through all files at that path
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basepath error:nil];
	for (NSString *fileName in files)
	{
		// if there's a file that matches the prefix
		if ([fileName hasPrefix:prefix])
		{
			NSString *path = [basepath stringByAppendingPathComponent:fileName];

			NSError* error = nil; // XXX
			NSDictionary* info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error ]; 
			NSDate* picDate = [info objectForKey:NSFileModificationDate]; 
			if (error) { // XXX why is this a string???
				NSLog(@"Error %@, %@", error, [error userInfo]);//[NSApp presentError:error]; 
			}    
			
			
			
			// Extract the date string and use natural language matching to get its date
			//NSString *datestring = [[[[[fileName stringByDeletingPathExtension] substringFromIndex:8] stringByReplacingOccurrencesOfString:@" at" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@":"] stringByAppendingString:@" -0600"];
			//NSDate *picDate = [NSDate dateWithNaturalLanguageString:datestring];
			
			// Determine the length of time since the screen was shot.
			NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:picDate];
			
			// Proceed if the time interval lies within 10 seconds
			// New extra time is to allow for better screen shot layout
			if (t < 10.0f)
			{
				if (![history containsObject:fileName]) {
					[history addObject:fileName]; // XXX This might grow a bit too big given enough time.
					
					// Get the full path and the actual image
					NSString *path = [basepath stringByAppendingPathComponent:fileName];
					NSLog(@"I want to upload %@", path);
					[list addObject:path];
					//NSImage *image = [[[NSImage alloc]  initWithContentsOfFile:path] autorelease];
					//
					//// Convert the image to jpeg (use "NSPNGFileType" for PNG)
					//NSArray *representations = [image representations];
					//NSData * bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations usingType:NSJPEGFileType properties:nil];
					//[bitmapData writeToFile:@"/tmp/foo.jpg" atomically:YES];
					//
					//// Upload the image
					//UploadOperation *op = [[[UploadOperation alloc] init] autorelease];
					//op.path = @"/tmp/foo.jpg";
					//op.delegate = self;
					//[op start];
				}
			}
		}
	}
	
	return list;
	
}
@end
