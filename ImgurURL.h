//
//  ImgurFile.h
//  Captured
//
//  Created by Christopher Sexton on 2/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImgurURL : NSObject {
@private
    NSString *imageURL;
    NSString *imageDeleteURL;
    
    
}

@property (assign) NSString *imageURL;
@property (assign) NSString *imageDeleteURL;


@end
