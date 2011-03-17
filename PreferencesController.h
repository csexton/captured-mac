//
//  PreferencesController.h
//  Captured
//
//  Created by Christopher Sexton on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PreferencesController  : NSObject <NSWindowDelegate> {

    NSWindow *window;
    NSBox *uploaderBox;
    NSView *sftpPreferences;
    NSView *s3Preferences;
    NSView *imgurPreferences;
    NSView *dropboxPreferences;

@private


}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSBox *uploaderBox;
@property (assign) IBOutlet NSView *sftpPreferences;
@property (assign) IBOutlet NSView *s3Preferences;
@property (assign) IBOutlet NSView *imgurPreferences;
@property (assign) IBOutlet NSView *dropboxPreferences;

-(IBAction) selectUploader:(id) sender;
-(void) selectUploaderViewWithType: (NSString *) type;


@end
