//
//  Utilities.m
//  Captured
//
//  Created by Christopher Sexton on 1/14/11.
//  Copyright 2011 Christopher Sexton. All rights reserved.
//

#import "Utilities.h"
#import "UrlShortener.h"
#import <Growl/Growl.h>

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
+(void)copyUrlToPasteboard:(NSString*)str shouldShorten:(BOOL)likesItStumpy {
    
    if (likesItStumpy) {
        str = [UrlShortener shorten:str];
    }
    return [Utilities copyToPasteboard:str];
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

+ (NSURL *)appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

+ (BOOL) willStartAtLogin:(NSURL *)itemURL
{
    Boolean foundIt=false;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
			
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                foundIt = CFEqual(URL, itemURL);
                CFRelease(URL);
				
                if (foundIt)
                    break;
            }
        }
        CFRelease(loginItems);
    }
    return (BOOL)foundIt;
}

// Might need to use SMLoginItemSetEnabled instead
+ (void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled
{
    //OSStatus status;
    LSSharedFileListItemRef existingItem = NULL;
	
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
			
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                Boolean foundIt = CFEqual(URL, itemURL);
                CFRelease(URL);
				
                if (foundIt) {
                    existingItem = item;
                    break;
                }
            }
        }
		
        if (enabled && (existingItem == NULL)) {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst,
                                          NULL, NULL, (CFURLRef)itemURL, NULL, NULL);
			
        } else if (!enabled && (existingItem != NULL))
            LSSharedFileListItemRemove(loginItems, existingItem);
		
        CFRelease(loginItems);
    }       
}

+ (NSImage*) thumbnailWithFile: (NSString*)path size:(NSSize)newSize {
    NSLog(@"Start resize image for history menu thumbnail");
    NSImage *sourceImage;
    NSImage *smallImage;
    
    sourceImage = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
    
    // Report an error if the source isn't a valid image
    if (![sourceImage isValid]) {
        @throw [NSException
                exceptionWithName:@"FileNotFoundException"
                reason:@"Original image was not valid, the uploader may not have set the FilePath key"
                userInfo:nil];
        return sourceImage; // Why do we get here?
    } else {
        
        NSSize smallSize = [sourceImage size];
        float rx, ry, r;
        rx = newSize.width / smallSize.width;
        ry = newSize.height / smallSize.height;
        r = rx < ry ? rx : ry;
        smallSize.width *= r;
        smallSize.height *= r;

        smallImage = [[[NSImage alloc] initWithSize:smallSize] autorelease];
        [smallImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage setScalesWhenResized:YES];
        [sourceImage setSize:smallSize];
        [sourceImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
        [smallImage unlockFocus];
    }

    return smallImage;
}
+ (void) growlError:(NSString*) str{
    [GrowlApplicationBridge notifyWithTitle:@"Captured had a Problem"
                                description:str
                           notificationName:@"Error"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:[NSDate date]];
}

@end
