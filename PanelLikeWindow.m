//
//  PanelLikeWindow.m
//  Captured
//
//  Created by Christopher Sexton on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PanelLikeWindow.h"

@implementation PanelLikeWindow

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)cancelOperation:(id)sender {
    [self close];
}

@end
