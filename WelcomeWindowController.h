//
//  WelcomeWindowController.h
//  Captured
//
//  Created by Christopher Sexton on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WelcomeWindowController : NSObject <NSWindowDelegate>{
    NSWindow *window;
@private
    
}

@property (assign) IBOutlet NSWindow *window;


@end
