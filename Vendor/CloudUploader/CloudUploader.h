//
//  CloudUploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudUploader : NSObject

- (nonnull id)initWithSettings:(NSDictionary* _Nullable)dict;

- (BOOL) uploadFile:(NSString * _Nonnull)filename;
- (NSString * _Nonnull)testConnection;

@property (retain, nullable) NSString *filePath;
@property (retain, nullable) NSString *uploadUrl;
@property (retain, nullable) NSString *deleteUrl;
@property BOOL success;

@property (nullable) NSString *accessKey;
@property (nullable) NSString *secretKey;
@property (nullable) NSString *bucket;
@property (nullable) NSString *publicUrl;
@property NSInteger nameLength;
@property BOOL reducedRedundancy;
@property BOOL privateUpload;
@property NSInteger minutesToExpiration;

@end