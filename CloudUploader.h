//
//  CloudUploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudUploader : NSObject {
}

- (NSInteger)uploadFile:(NSString*)sourceFile;
- (NSInteger)testConnection;

@end
