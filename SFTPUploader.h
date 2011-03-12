//
//  SFTPUploader.h
//  Captured
//
//  Created by Jorge Velázquez on 3/11/11.
//  Copyright 2011 Christopher Sexton. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <curl/curl.h>

@interface SFTPUploader : NSObject {
	CURL* handle;
}

@property CURL* handle;

- (int)uploadFile:(NSString*)sourceFile host:(NSString*)host username:(NSString*)username password:(NSString*)password targetDir:(NSString*)targetDir;
- (CURL*)handle;

@end
