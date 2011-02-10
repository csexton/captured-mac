//
//  Utilities.h
//  Captured
//
//  Created by Christopher Sexton on 1/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Utilities : NSObject {

}

+(NSDictionary*)screenCapturePrefs;
+(NSString*)screenCaptureDir;
+(NSString*)screenCapturePrefix;
+(void)copyToPasteboard:(NSString*)str;
+(NSString*)invokeScreenCapture:(NSString*)option;
+ (NSURL *)appURL;
+(BOOL) willStartAtLogin:(NSURL *)itemURL;
+(void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;


@end
