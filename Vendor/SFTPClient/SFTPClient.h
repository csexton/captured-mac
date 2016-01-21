//
//  SFTPUploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/11/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <curl/curl.h>

@interface SFTPClient : NSObject

- (id)initWithSettings:(NSDictionary *)dict;

- (void)uploadThread:(NSString *)sourceFile;
- (BOOL)uploadFile:(NSString *)sourceFile;
- (NSString *)testConnection;

@property (retain) NSString *uploadUrl;
@property BOOL success;
@property NSString *password;

@property NSString *host;
@property NSString *username;
@property NSString *targetDir;
@property NSString *publicKeyFile;
@property NSString *privateKeyFile;
@property NSString *keyPassword;

@end
