//
//  ImgurController.h
//  Captured
//
//  Created by Christopher Sexton on 1/12/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ASIFormDataRequest.h"
#import "AbstractUploader.h"


@interface ImgurUploader : AbstractUploader {
	NSData *imageSelection;
    NSData *imageSelectionData;
	NSData *xmlResponseData;
    NSString *filePathName;

}

@property (retain) NSData *imageSelection;
@property (retain) NSData *imageSelectionData;
@property (retain) NSData *xmlResponseData;
@property (retain) NSString *filePathName;

- (void) performUpload: (NSData *) image;
- (void) requestFinished: (ASIFormDataRequest *) request;
- (void) requestFailed: (ASIFormDataRequest *) request;
- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

- (void) uploadFile:(NSString*)filename;
- (NSDictionary*) parseResponseForURL:(NSString*)str;

-(void)unlinkAccount;
- (NSString*)linkAccount: (NSString *)user password:(NSString *)password;
@end
