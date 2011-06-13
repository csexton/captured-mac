//
//  AbstractUploader.h
//  Captured
//
//  Created by Christopher Sexton on 3/25/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AbstractUploader : NSObject {
	NSString* filePath;
	NSString* uploadUrl;
	NSString* deleteUrl;
}

@property (retain) NSString* filePath;
@property (retain) NSString* uploadUrl;
@property (retain) NSString* deleteUrl;

// Virtual Interface, these should be be implemented in the subclass
- (void) uploadFile:(NSString*)filename;
- (void) deleteImage:(NSString*)deleteImageURL;
- (NSString*)testConnection;


// Called to notify the application the upload has started
- (void) uploadStarted;

// Called to notify the application the upload sas succeeded
- (void) uploadSuccess: (NSDictionary *) details;

// Called to notify the application the upload has failed
- (void) uploadFailed: (NSDictionary *) details;


@end
