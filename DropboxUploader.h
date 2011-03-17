//
//  DropboxUploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <curl/curl.h>

@interface DropboxUploader : NSObject {
	CURL* handle;
}

@property CURL* handle;

- (NSInteger)uploadFile:(NSString*)sourceFile;
- (NSInteger)testConnection;
- (NSString*)genRandStringLength:(int)len seed:(unsigned long)seed;
- (NSString*)genSigBaseString:(NSString*)url method:(NSString*)method fileName:(const char*)fileName consumerKey:(const char*)consumerKey nonce:(NSString*)nonce timestamp:(unsigned long)timestamp token:(NSString*)token;
- (NSString*)genOAuthSig:(NSString*)sigBaseString consumerSecret:(const char*)consumerSecret userSecret:(NSString*)userSecret;
- (NSString*)genAuthHeader:(const char*)fileName consumerKey:(const char*)consumerKey signature:(NSString*)signature nonce:(NSString*)nonce timestamp:(unsigned long)timestamp token:(NSString*)token;
- (NSInteger)getToken:(NSString*)username password:(NSString*)password;
- (NSUInteger)getAccountId;
- (CURL*)handle;

@end
