//
//  PreferencesController.h
//  Captured
//
//  Created by Christopher Sexton on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PreferencesController  : NSViewController <NSWindowDelegate> {

    NSWindow *window;
    NSBox *uploaderBox;
    NSView *sftpPreferences;
    NSView *s3Preferences;
    NSView *imgurPreferences;
    NSView *dropboxPreferences;
    BOOL isWindowOpen;

@private


}

@property (retain) IBOutlet NSWindow *window;
@property (retain) IBOutlet NSBox *uploaderBox;
@property (retain) IBOutlet NSView *sftpPreferences;
@property (retain) IBOutlet NSView *s3Preferences;
@property (retain) IBOutlet NSView *imgurPreferences;
@property (retain) IBOutlet NSView *dropboxPreferences;

-(IBAction) selectUploader:(id) sender;
-(IBAction) showpreferencesWindow: (id) sender;
-(void) selectUploaderViewWithType: (NSString *) type;


@end
