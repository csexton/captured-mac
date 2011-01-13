//
//  Captured_AppDelegate.h
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright Codeography 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Captured_AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}


@property (assign) IBOutlet NSWindow *window;

- (void)initEventsController;


@end