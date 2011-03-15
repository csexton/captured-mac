//
//  S3Uploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <curl/curl.h>

@interface S3Uploader : NSObject {
	CURL* handle;
}

@property CURL* handle;

- (NSInteger)uploadFile:(NSString*)sourceFile;
- (NSInteger)testConnection;
- (CURL*)handle;

@end
