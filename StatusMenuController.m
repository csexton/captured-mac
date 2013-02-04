//
//  MainController.m
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "ImgurUploader.h"


#import "StatusMenuController.h"
#import "CapturedAppDelegate.h"
#import "Utilities.h"
#import "MenuItemWithDict.h"

@implementation StatusMenuController
@synthesize lastUploadedURL;
@synthesize lastUploadedDeleteURL;
@synthesize clipURLMenuItem;
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

    [errorMsgMenuItem setHidden:YES];
    [errorMsgSepMenuItem setHidden:YES];
}
-(void) setStatusFailure {
	[self setStatusIcon: statusIconError];
    
    // TODO:  NSUserNotificationCenter error alert!!!
    
    [errorMsgMenuItem setHidden:NO];
    [errorMsgSepMenuItem setHidden:NO];
}


- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NSLog(@"Status Menu Controller - didActivateNotification!");
}

-(void) setStatusSuccess: (NSDictionary*)dict {

    // Update the icon
	[self setStatusIcon: statusIconSuccess];
	[self performSelector: @selector(setStatusNormal) withObject: nil afterDelay: 5.0];
    
    // Save the last url (TODO: not needed b/c of history?)
	self.lastUploadedURL = [NSString stringWithString:[dict valueForKey:@"ImageURL"]];
	self.lastUploadedDeleteURL = [NSString stringWithString:[dict valueForKey:@"DeleteImageURL"]];

    // Copy url to clipboard
	[clipURLMenuItem setEnabled:YES];
    BOOL useShort = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UseURLShortener"] boolValue];
	[Utilities copyUrlToPasteboard:[dict valueForKey:@"ImageURL"] shouldShorten:useShort];
    
    
    //Initalize new notification
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    //Set the title of the notification
    [notification setTitle:@"Upload Finished"];
    //Set the text of the notification
    [notification setInformativeText:@"Successfully Uploaded Screenshot and Copied the URL to the Clipboard"];
    //Set the time and date on which the nofication will be deliverd (for example 20 secons later than the current date and time)
    [notification setDeliveryDate:[NSDate dateWithTimeInterval:0 sinceDate:[NSDate date]]];
    //Set the sound, this can be either nil for no sound, NSUserNotificationDefaultSoundName for the default sound (tri-tone) and a string of a .caf file that is in the bundle (filname and extension)
    [notification setSoundName:NSUserNotificationDefaultSoundName];
    
    //Get the default notification center
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    //Scheldule our NSUserNotification
    [center scheduleNotification:notification];

   
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
    // Add the menu item
    BOOL showMenuItem = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowStatusMenuItem"] boolValue];
    if (showMenuItem){
        [self addStatusItem];   
    }
}

- (void)addStatusItem
{
	//statusIcon = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"StatusMenuIcon" ofType:@"png"]] retain];
    statusIcon = [NSImage imageNamed:@"StatusMenuIcon"];
	statusIconSelected = [NSImage imageNamed:@"StatusMenuIconSelected"];
	statusIconSuccess = [NSImage imageNamed:@"StatusMenuIconSuccess"];
	statusIconColor = [NSImage imageNamed:@"StatusMenuIconColor"];
	statusIconDisabled = [NSImage imageNamed:@"StatusMenuIconDisabled"];
	statusIconError = [NSImage imageNamed:@"StatusMenuIconError"];
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
