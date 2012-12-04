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

- (void)linkAccount;
- (void)getAccountInfo;
- (BOOL)isAccountLinked;
- (void)unlinkAccount;

@end
