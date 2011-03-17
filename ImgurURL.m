//
//  ImgurFile.m
//  Captured
//
//  Created by Christopher Sexton on 2/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "ImgurURL.h"


@implementation ImgurURL

@synthesize imageURL;
@synthesize imageDeleteURL;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
