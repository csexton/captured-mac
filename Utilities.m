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

@end
