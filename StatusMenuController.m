//
//  MainController.m
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Growl/Growl.h>
#import "ImgurUploader.h"

#import "StatusMenuController.h"
#import "CapturedAppDelegate.h"
#import "Utilities.h"
#import "MenuItemWithDict.h"

@implementation StatusMenuController
@synthesize lastUploadedURL;
@synthesize lastUploadedDeleteURL;
@synthesize copyURLMenuItem;
@synthesize historyMenu;

-(void) setStatusIcon: (NSImage*)icon {
	// Seems that a crash occurs if you try to set the menu title from a thread other than the main thread.
	if ([NSThread isMainThread])
	{
		[statusItem setImage:icon];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(setStatusIcon:) withObject:icon waitUntilDone:YES];
	}
}

-(void) setStatusNormal {
	[self setStatusIcon: statusIcon];
}
-(void) setStatusDisabled {
	[self setStatusIcon: statusIconDisabled];
    [errorMsgMenuItem setHidden:YES];
    [errorMsgSepMenuItem setHidden:YES];
}
-(void) setStatusProcessing {
	[self setStatusIcon: statusIconColor];
    [GrowlApplicationBridge notifyWithTitle:@"Captured"
                                description:@"Uploading Screenshot"
                           notificationName:@"Upload Started"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:[NSDate date]];
    [errorMsgMenuItem setHidden:YES];
    [errorMsgSepMenuItem setHidden:YES];
}
-(void) setStatusFailure {
	[self setStatusIcon: statusIconError];
    
    [GrowlApplicationBridge notifyWithTitle:@"Captured"
                                description:@"Failed to Upload Screenshot. \n\nClick here to edit Captured's Preferences."
                           notificationName:@"Upload Failed"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@"errorMessageClicked"];
    [errorMsgMenuItem setHidden:NO];
    [errorMsgSepMenuItem setHidden:NO];
}

- (void) growlNotificationWasClicked:(id)clickContext{
    if (clickContext && [clickContext isEqualToString:@"errorMessageClicked"]) {
        [AppDelegate showPreferencesWindow:nil];
    }
}

-(void) setStatusSuccess: (NSDictionary*)dict {

    // Update the icon
	[self setStatusIcon: statusIconSuccess];
	[self performSelector: @selector(setStatusNormal) withObject: nil afterDelay: 5.0];
    
    // Save the last url (TODO: not needed b/c of history?)
	self.lastUploadedURL = [NSString stringWithString:[dict valueForKey:@"ImageURL"]];
	self.lastUploadedDeleteURL = [NSString stringWithString:[dict valueForKey:@"DeleteImageURL"]];

    // Copy url to clipboard
	[copyURLMenuItem setEnabled:YES];
    BOOL useShort = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UseURLShortener"] boolValue];
	[Utilities copyUrlToPasteboard:[dict valueForKey:@"ImageURL"] shouldShorten:useShort];
    
    // Send growl notification
    [GrowlApplicationBridge notifyWithTitle:@"Captured"
                                description:@"Successfully Uploaded Screenshot and Copied the URL to the Clipboard"
                           notificationName:@"Upload Finished"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:[NSDate date]];
   
    // Jump to the background thread to do the resizing
    [self performSelectorInBackground: @selector(createHistoryMenuItem:) withObject: dict];
                              
    // Play a sound
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"PlaySoundAfterUpload"] boolValue]) {
    	[[NSSound soundNamed:@"Hero"] play];
    }
}
-(void) createHistoryMenuItem: (NSDictionary *) dict {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    // Create history menu item
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"dMMMhhmma" options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];

    MenuItemWithDict *menuItem = [[MenuItemWithDict alloc]
                                  initWithTitle:[@"Captured on " stringByAppendingString:dateString]
                                  action:@selector(historyMenuItemAction:) 
                                  keyEquivalent:@""];
    
    // Add the dict from the uploader
    [menuItem setTarget:self];
    menuItem.dict = dict;
    
    // Create the tnumbnail
    @try {
        NSString *imageFilePath = [dict valueForKey:@"FilePath"];
        if (imageFilePath != nil){
            NSImage *img = [Utilities thumbnailWithFileMaintainWidth:[dict valueForKey:@"FilePath"] size:NSMakeSize(64, 64)];
            [menuItem setImage:img];
        }
    }
    @catch ( NSException *e ) {
        NSLog(@"Unable to create thumbnail for history item: %@", e);
    }
   
    // Jump back the main thread to add the menu item to the history menu
    [self performSelectorOnMainThread:@selector(addHistoryMenuItem:) withObject:menuItem waitUntilDone:YES];
    //[historyMenu addItem:menuItem];
    [menuItem release];
	[pool release];
}
-(void)addHistoryMenuItem:(NSMenuItem*) menuItem{
    [self willChangeValueForKey:@"enableHistoryMenu"];
    NSInteger num = [[NSUserDefaults standardUserDefaults] integerForKey:@"NumberOfHistoryItems"];
    if([historyMenu numberOfItems] >= num) {
       [historyMenu removeItemAtIndex:(num-1)];
    }
    //[historyMenu addItem:menuItem];
    [historyMenu insertItem:menuItem atIndex:0];
    [self didChangeValueForKey:@"enableHistoryMenu"];

}


-(IBAction) historyMenuItemAction: (id) sender{
    MenuItemWithDict *item = (MenuItemWithDict *) sender;
    NSString *url = [item.dict valueForKey:@"ImageURL"];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

-(void) awakeFromNib
{
    NSBundle *myBundle = [NSBundle bundleForClass:[CapturedAppDelegate class]];
	NSString *growlPath = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
    
	if (growlBundle && [growlBundle load]) {
		// Register ourselves as a Growl delegate
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	else {
		NSLog(@"ERROR: Could not load Growl.framework");
	}
    

    // Add the menu item
    BOOL showMenuItem = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowStatusMenuItem"] boolValue];
    if (showMenuItem){
        [self addStatusItem];   
    }

	

    
}

- (void)addStatusItem
{
	statusIcon = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIcon" ofType:@"png"]] retain];
	statusIconSelected = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIconSelected" ofType:@"png"]] retain];
	statusIconSuccess = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIconSuccess" ofType:@"png"]] retain];
	statusIconColor = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIconColor" ofType:@"png"]] retain];
	statusIconDisabled = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIconDisabled" ofType:@"png"]] retain];
	statusIconError = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIconError" ofType:@"png"]] retain];
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	[statusItem setImage:statusIcon];
    [statusItem setAlternateImage:statusIconSelected];
	[statusItem setHighlightMode:YES];    
    
}


- (IBAction)toggleStatusMenuItem:(id) sender
{
    if ([sender state] == NSOnState) {
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"ShowStatusMenuItem"];
        [self addStatusItem];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:@"Are you sure you want to do that?"];
        [alert setInformativeText:@"It is suggested you keep this option selected. With the Menu Bar Icon hidden there is no easy way to edit the preferences."];
        
        [alert beginSheetModalForWindow:[sender window]
                          modalDelegate:self
                         didEndSelector:@selector(toggleStatusMenuAlertDidEnd:returnCode:contextInfo:)
                            contextInfo:sender];
    }
}

- (void)toggleStatusMenuAlertDidEnd:(NSAlert *)alert
                         returnCode:(int)returnCode contextInfo:(id)contextInfo {
    [alert release];
    [[statusItem statusBar] removeStatusItem:statusItem];  
    [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"ShowStatusMenuItem"];
}

-(IBAction) quitItemAction:(id) sender
{
	[[NSApplication sharedApplication] terminate:self];	
}

-(IBAction) copyURLItemAction:(id) sender
{
	[Utilities copyToPasteboard:self.lastUploadedURL];
}

-(IBAction) openURLInBrowserAction:(id) sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lastUploadedURL]];
}

-(IBAction) openDeleteURLInBrowserAction:(id) sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lastUploadedDeleteURL]];
}

- (BOOL)startAtLogin
{
    return [Utilities willStartAtLogin:[Utilities appURL]];
}

- (void)setStartAtLogin:(BOOL)enabled
{
    [self willChangeValueForKey:@"startAtLogin"];
    [Utilities setStartAtLogin:[Utilities appURL] enabled:enabled];
    [self didChangeValueForKey:@"startAtLogin"];
}

-(BOOL) isURLAvaliable
{
    if ([self.lastUploadedURL length] == 0) {
        return NO;
    } else {
        
        return YES;
    }
}

-(BOOL) enableHistoryMenu
{
    return ([historyMenu numberOfItems] > 0);
}

@end
