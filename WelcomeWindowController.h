//
//  WelcomeWindowController.h
//  Captured
//
//  Created by Christopher Sexton on 2/10/11.
//  Copyright 2011 Christopher Sexton. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WelcomeWindowController : NSObject <NSWindowDelegate>{
    NSWindow *window;
    NSButton *startCheckBox;

@private
    
}

@property BOOL startAtLogin;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *startCheckBox;

@end
