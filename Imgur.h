//
//  ImgurController.h
//  Captured
//
//  Created by Christopher Sexton on 1/12/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ASIFormDataRequest.h"
#import "ImgurURL.h"


@interface Imgur : NSObject {
	NSData *imageSelection;
    NSData *imageSelectionData;
	NSData *xmlResponseData;

}

@property (retain) NSData *imageSelection;
@property (retain) NSData *imageSelectionData;
@property (retain) NSData *xmlResponseData;

- (void) uploadImage: (NSData *) image;
- (void) requestFinished: (ASIFormDataRequest *) request;
- (void) requestFailed: (ASIFormDataRequest *) request;
- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

- (void) processFile:(NSString*)filename;
- (ImgurURL *) parseResponseForURL:(NSString*)str;

@end
