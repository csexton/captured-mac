//
//  CloudUploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <curl/curl.h>

@interface CloudUploader : NSObject {
	CURL* handle;
}

@property CURL* handle;

- (NSInteger)uploadFile:(NSString*)sourceFile;
- (NSInteger)testConnection;
- (CURL*)handle;

@end

@interface NSData(WithBase64)

/**
 * Return a base64 encoded representation of the data.
 *
 * @return base64 encoded representation of the data.
 */
- (NSString *) base64EncodedString;

@end
