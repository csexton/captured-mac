//
//  DropboxUploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AbstractUploader.h"

@interface DropboxUploader : AbstractUploader

- (NSString*)linkAccount:(NSString*)email password:(NSString*)password;
- (void)getAccountInfo;
- (BOOL)isAccountLinked;
- (void)unlinkAccount;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end
