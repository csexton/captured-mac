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
+(NSURL *)appURL;
+(BOOL) willStartAtLogin:(NSURL *)itemURL;
+(void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;
+(NSImage*) thumbnailWithFileMaintainWidth: (NSString*)path size:(NSSize)newSize;
+(NSImage*) thumbnailWithFile: (NSString*)path size:(NSSize)newSize;
+(void) growlError:(NSString*) str;
+(NSString*) getHmacSha1:(NSString*)stringToSign secretKey:(NSString*)secretKey;
+(NSString*)URLEncode:(NSString*)stringToEncode;
+(NSString*)createUniqueFilename:(NSInteger) numChars;
+(NSString*)removeAnyTrailingSlashes: (NSString*)str;
+(NSString*)genRandString;
+(NSString*)genSigBaseString:(NSString*)url method:(NSString*)method fileName:(NSString*)fileName consumerKey:(NSString*)consumerKey nonce:(NSString*)nonce timestamp:(unsigned long)timestamp token:(NSString*)token;
+(NSString*)genAuthHeader:(NSString*)fileName consumerKey:(NSString*)consumerKey signature:(NSString*)signature nonce:(NSString*)nonce timestamp:(unsigned long)timestamp token:(NSString*)token;

@end

@interface NSData(WithBase64)

/**
 * Return a base64 encoded representation of the data.
 *
 * @return base64 encoded representation of the data.
 */
- (NSString*) base64EncodedString;

@end
