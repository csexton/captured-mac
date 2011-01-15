//
//  ImgurController.h
//  Captured
//
//  Created by Christopher Sexton on 1/12/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "ASIFormDataRequest.h"

#import <Cocoa/Cocoa.h>


@interface ImgurController : NSObject {
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
- (NSString *) parseResponseForURL:(NSString*)str;

@end
