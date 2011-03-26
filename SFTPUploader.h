//
//  SFTPUploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/11/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <curl/curl.h>

#import "AbstractUploader.h"

@interface SFTPUploader : AbstractUploader {
	CURL* handle;
}

@property CURL* handle;

- (void)uploadFile:(NSString*)sourceFile;
- (NSInteger)testConnection;

@end
