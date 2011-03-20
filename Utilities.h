//
//  Utilities.h
//  Captured
//
//  Created by Christopher Sexton on 1/14/11.
//  Copyright 2011 Christopher Sexton. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Utilities : NSObject {

}

+(NSDictionary*)screenCapturePrefs;
+(NSString*)screenCaptureDir;
+(NSString*)screenCapturePrefix;
+(void)copyToPasteboard:(NSString*)str;
+(void)copyUrlToPasteboard:(NSString*)str shouldShorten:(BOOL)shouldShorten;
+(NSString*)invokeScreenCapture:(NSString*)option;
+ (NSURL *)appURL;
+(BOOL) willStartAtLogin:(NSURL *)itemURL;
+(void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;
+ (NSImage*) thumbnailWithFile: (NSString*)path size:(NSSize)newSize;


@end
