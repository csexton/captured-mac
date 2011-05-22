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
#import <CommonCrypto/CommonHMAC.h>

static char alNum[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

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
    [dateFormat release];
    [now release];

	
	NSString* path = [NSString stringWithFormat:@"%@captured-%@.png", NSTemporaryDirectory(), timestamp];
	
	//NSLog(@"Saving to temp path: %@", path);
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


// Sorta hackish. This will create the thumbnail by scaling the image to be 64 pixels wide and then cropping 
// starting at the bottom left corner if it is more than 64 pixels tall
+ (NSImage*) thumbnailWithFileMaintainWidth: (NSString*)path size:(NSSize)newSize {
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
        float r = newSize.width / smallSize.width;
        smallSize.width *= r;
        smallSize.height *= r;
        
        smallImage = [[[NSImage alloc] initWithSize:smallSize] autorelease];
        [smallImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage setScalesWhenResized:YES];
        [sourceImage setSize:smallSize];
        [sourceImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
        [smallImage unlockFocus];
        
        if (smallSize.height > newSize.height) {
            NSImage *cropImage;
            
            cropImage = [[[NSImage alloc] initWithSize:newSize] autorelease];
            [cropImage lockFocus];
            [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
            //[smallImage setScalesWhenResized:YES];

            [smallImage setSize:newSize];
            [smallImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
            [cropImage unlockFocus];
            return cropImage; 
        }
    }
    
    return smallImage;
}



+ (NSImage*) thumbnailWithFile: (NSString*)path size:(NSSize)newSize {
    //NSLog(@"Start resize image for history menu thumbnail");
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
    NSLog(@"Notifying user of error: '%@'", str);
    [GrowlApplicationBridge notifyWithTitle:@"Captured had a Problem"
                                description:str
                           notificationName:@"Error"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:[NSDate date]];
}

+(NSString*) getHmacSha1:(NSString*)stringToSign secretKey:(NSString*)secretKey
{
	// create the signature
	CCHmacContext context;
	NSData* dataToSign = [stringToSign dataUsingEncoding:NSASCIIStringEncoding];
	unsigned char digestRaw[CC_SHA1_DIGEST_LENGTH];
	CCHmacInit(&context, kCCHmacAlgSHA1, [secretKey cStringUsingEncoding:NSASCIIStringEncoding], [secretKey length]);
	CCHmacUpdate(&context, [dataToSign bytes], [dataToSign length]);
	CCHmacFinal(&context, digestRaw);
	NSData* digestData = [NSData dataWithBytes:digestRaw length:CC_SHA1_DIGEST_LENGTH];
	return [digestData base64EncodedString];
}

+(NSString*)URLEncode:(NSString*)stringToEncode
{
	CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
	CFStringRef escapeChars = (CFStringRef) @":?=,!$&'()*+;[]@#~/";
	
	return [(NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) stringToEncode, NULL, escapeChars, encoding) autorelease];
}

+(NSString*)createUniqueFilename:(NSInteger) numChars
{
	char buf[32];
	srand(time(NULL));
	for (int i = 0; i < numChars; i++)
		buf[i] = alNum[rand() % strlen(alNum)];
	buf[numChars] = 0;
	strcat(buf, ".png");
	return [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
}

+ (NSString*)removeAnyTrailingSlashes: (NSString*)str
{
    if (str) {
        if( [str hasSuffix: @"/"] ){	// Remove any trailing slashes that might screw up removal.    
            return [str substringToIndex:[str length] - 1];
        }
    }
    return str;
}

@end

static char base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSData (WithBase64)

- (NSString *) base64EncodedString
{
	NSMutableString *result;
	unsigned char   *raw;
	unsigned long length;
	short i, nCharsToWrite;
	long cursor;
	unsigned char inbytes[3], outbytes[4];
	
	length = [self length];
	
	if (length < 1)
		return @"";
	
	result = [NSMutableString stringWithCapacity:length];
	raw = (unsigned char *)[self bytes];
	
	// Take 3 chars at a time, and encode to 4
	for (cursor = 0; cursor < length; cursor += 3) {
		
		for (i = 0; i < 3; i++) {
			if (cursor + i < length) 
				inbytes[i] = raw[cursor + i];
			else 
				inbytes[i] = 0;
		}
		
		outbytes[0] = (inbytes[0] & 0xFC) >> 2;
		outbytes[1] = ((inbytes[0] & 0x03) << 4) | ((inbytes[1] & 0xF0) >> 4);
		outbytes[2] = ((inbytes[1] & 0x0F) << 2) | ((inbytes[2] & 0xC0) >> 6);
		outbytes[3] = inbytes[2] & 0x3F;
		
		nCharsToWrite = 4;
		
		switch (length - cursor) {
			case 1:
				nCharsToWrite = 2;
				break;
			case 2:
				nCharsToWrite = 3;
				break;
		}
		
		for (i = 0; i < nCharsToWrite; i++) {
			[result appendFormat:@"%c", base64EncodingTable[outbytes[i]]];
		}
		
		for (i = nCharsToWrite; i<4; i++) {
			[result appendString:@"="];
		}
	}
	
	return [NSString stringWithString:result]; // convert to immutable string
}



@end
