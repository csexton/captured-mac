//
//  CloudUploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudUploader : NSObject

- (id)initWithSettings:(NSDictionary*)dict;

- (BOOL) uploadFile:(NSString*)filename;
- (NSString*)testConnection;

@property (retain) NSString *filePath;
@property (retain) NSString *uploadUrl;
@property (retain) NSString *deleteUrl;
@property BOOL success;

@property NSString *accessKey;
@property NSString *secretKey;
@property NSString *bucket;
@property NSString *publicUrl;
@property NSInteger nameLength;
@property BOOL reducedRedundancy;
@property BOOL privateUpload;
@property NSInteger minutesToExpiration;

@end