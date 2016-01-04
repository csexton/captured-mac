//
//  CloudUploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudUploader : NSObject

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

// Virtual Interface, these should be be implemented in the subclass
- (void) uploadFile:(NSString*)filename;
- (void) deleteImage:(NSString*)deleteImageURL;
- (NSString*)testConnection;


@property (retain) NSString *filePath;
@property (retain) NSString *uploadUrl;
@property (retain) NSString *deleteUrl;


@end