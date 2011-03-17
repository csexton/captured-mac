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
- (CURL*)handle;

@end
