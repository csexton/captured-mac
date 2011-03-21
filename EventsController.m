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
#import "CapturedAppDelegate.h"
#import "ImgurUploader.h"
#import "SFTPUploader.h"
#import "CloudUploader.h"
#import "DropboxUploader.h"

@implementation EventsController

@synthesize screenCapturePrefix;
@synthesize screenCaptureDir;
@synthesize history;
@synthesize imgurUploader;
@synthesize sftpUploader;
@synthesize cloudUploader;
@synthesize dropboxUploader;

/**
 * Sets up the event listener using SCEvents and sets its delegate to this controller.
 * The event stream is started by calling startWatchingPaths: while passing the paths
 * to be watched.
 */
- (void)setupEventListener
{
	// Load this into a member var so we don't have to read the plist every time the 
	// event gets fired	
	self.screenCapturePrefix = [Utilities screenCapturePrefix];
	self.screenCaptureDir = [Utilities screenCaptureDir];
	self.history = [[NSMutableSet alloc] init]; 
	self.imgurUploader = [[ImgurUploader alloc] init]; //Leak?
	self.sftpUploader = [[[SFTPUploader alloc] init] autorelease];
	self.cloudUploader = [[[CloudUploader alloc] init] autorelease];
	self.dropboxUploader = [[[DropboxUploader alloc] init] autorelease];

    DirEvents *events = [DirEvents sharedPathWatcher];
    
    [events setDelegate:self];
	    
	NSMutableArray *paths = [NSMutableArray arrayWithObject:screenCaptureDir];
	
	// Start receiving events
	[events startWatchingPaths:paths];
	
	events.ignoreEventsFromSubDirs = YES;

	// Display a description of the stream
	//NSLog(@"%@", [events streamDescription]);	
}

/**
 * This is the only method to be implemented to conform to the SCEventListenerProtocol.
 * As this is only an example the event received is simply printed to the console.
 */
- (void)pathWatcher:(DirEvents *)pathWatcher eventOccurred:(DirEvent *)event
{
	NSArray *list = [self findFilesWithPrefix:screenCapturePrefix inDir:screenCaptureDir];
	
	for (NSString *path in list) {
		[self processFile:path];
	}
}

- (void)processFile: (NSString*)file {
	if ([[NSFileManager defaultManager] fileExistsAtPath:file] ){
        NSString * uploadType = [[NSUserDefaults standardUserDefaults] stringForKey:@"UploadType"];
        
        // To make this simple, these keys must match the values in the GUI exactly. If you want 
        // to add a type, add it in the MainMenu.xib's UploadType combobox
        
        if ([uploadType isEqualToString:@"Imgur"]){
            [imgurUploader uploadFile:file];
        } 
        else if ([uploadType isEqualToString:@"Amazon S3"])
        {
            NSInteger rc = [cloudUploader uploadFile:file];
        } 
        else if ([uploadType isEqualToString:@"Dropbox"])
        {
            NSInteger rc = [dropboxUploader uploadFile:file];
        } 
        else if ([uploadType isEqualToString:@"SFTP"]) 
        {
            NSInteger rc = [sftpUploader uploadFile:file];
        } 
        else 
        { // Fallback to Imgur
            NSLog(@"Unknown upload type '%@', using Imgur", uploadType);
            [imgurUploader uploadFile:file];
        }
    }
}

- (NSArray *)findFilesWithPrefix: (NSString*)prefix inDir:(NSString*)basepath{
	
//	NSMutableArray *list = [[NSMutableArray alloc] init]; 
	NSMutableArray *list = [NSMutableArray array]; 


	// Iterate through all files at that path
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basepath error:nil];
	for (NSString *fileName in files)
	{
		// if there's a file that matches the prefix
		if ([fileName hasPrefix:prefix])
		{
			NSString *path = [basepath stringByAppendingPathComponent:fileName];

			NSError* error = nil; 
			NSDictionary* info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error ]; 
			NSDate* picDate = [info objectForKey:NSFileModificationDate]; 
			if (error) { 
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
					
					// Cannot check if uploads are enabled until after we add the filename to the history
					// array because if someone disables uploads, takes a screen capture, then reneables them
					// within 10 seconds captured will upload it anyway.
					if ([(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadsEnabled]) {
					
					// Get the full path and the actual image
					NSString *path = [basepath stringByAppendingPathComponent:fileName];
					NSLog(@"I want to upload %@", path);
					[list addObject:path];

					}
				}
			}
		}
	}
	
	return list;
	
}
@end
