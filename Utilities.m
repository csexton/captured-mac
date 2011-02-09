//
//  Utilities.m
//  Captured
//
//  Created by Christopher Sexton on 1/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"


@implementation Utilities


+(NSDictionary*)screenCapturePrefs {
	NSString *scprefspath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.apple.screencapture.plist"];
	return [NSDictionary dictionaryWithContentsOfFile:scprefspath];
}
	
	
+(NSString*)screenCaptureDir {
	NSDictionary *scdict = [self screenCapturePrefs];
	
	// Get path
	NSString *basepath = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
	if (scdict && [scdict objectForKey:@"location"]) {
		basepath = [scdict objectForKey:@"location"];
	}
	
	return basepath;
}

+(NSString*)screenCapturePrefix {
	NSDictionary *scdict = [self screenCapturePrefs];
	
	// Get prefix
	NSString *prefix = @"Screen shot";
	if (scdict && [scdict objectForKey:@"name"]) {
		prefix = [scdict objectForKey:@"name"];
	}
		
	return prefix;
}

+(void)copyToPasteboard:(NSString*)str
{
	NSLog(@"Image URL copied to clipboard %@", str);
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
    [pb declareTypes:types owner:self];
    [pb setString: str forType:NSStringPboardType];
}

+(NSString*)invokeScreenCapture:(NSString*)option
{
	NSLog(@"%@", @"Start Capture Screen");
	
	// Get temp directory
	//NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	//NSString* cacheDir = [paths objectAtIndex:0];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSSSSS"];
	NSDate *now = [[NSDate alloc] init];
	NSString *timestamp = [dateFormat stringFromDate:now];
	
	NSString* path = [NSString stringWithFormat:@"%@captured-%@.png", NSTemporaryDirectory(), timestamp];
	
	NSLog(@"Saving to temp path: %@", path);
	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: @"/usr/sbin/screencapture"];
	
	NSArray *arguments;
	arguments = [NSArray arrayWithObjects:option, path, nil];
	[task setArguments: arguments];
	
	[task launch];
	[task waitUntilExit];
	
	[task release];
	
	return path;
}

@end
