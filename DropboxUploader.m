//
//  DropboxUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "Utilities.h"
#import "JSON/JSON.h"
#import "DropboxUploader.h"
#import <DropboxOSX/DropboxOSX.h>

// these are the Dropbox API keys, keep them safe
static NSString* oauthConsumerKey = @"4zwv9noh6qesnob";
static NSString* oauthConsumerSecretKey = @"folukm6dwd1l93r";

@implementation DropboxUploader

- (void)uploadFile:(NSString*)sourceFile
{
    [self setFilePath:sourceFile];
    
    // generate a unique filename
    NSString* tempNam = [Utilities createUniqueFilename:5];
    
    // set up the session, we are using the app folder
    DBSession *session = [[DBSession alloc] initWithAppKey:oauthConsumerKey appSecret:oauthConsumerSecretKey root:kDBRootDropbox];
    
    // if we're not linked, we can't do anything yet, so inform the user
    if (![session isLinked])
    {
        [self uploadFailed:nil];
        [session release];
        NSLog(@"Cannot upload to Dropbox, account is not linked");
        return;
    }
    
    // set this as our session and create the rest client
    [DBSession setSharedSession:session];
    DBRestClient* restClient = [[DBRestClient alloc] initWithSession:session];
    
    // do the upload
    [restClient uploadFile:tempNam toPath:@"/Captured/" withParentRev:nil fromPath:sourceFile];
    
    // clean up
    [restClient release];
    [session release];
}

- (void)linkAccount {
    // set up the session, we are using the app folder
    DBSession *session = [[DBSession alloc] initWithAppKey:oauthConsumerKey appSecret:oauthConsumerSecretKey root:kDBRootDropbox];
    [DBSession setSharedSession:session];
    
    // call the authenticator, which will link the account
    [[DBAuthHelperOSX sharedHelper] authenticate];
    
    // clean up
    [session release];
}

- (void)getAccountInfo {
    // create the session, must already be linked
    DBSession *session = [[DBSession alloc] initWithAppKey:oauthConsumerKey appSecret:oauthConsumerSecretKey root:kDBRootDropbox];
    if (![session isLinked])
    {
        [session release];
        return;
    }
    
    // create the rest client so we can load the account info
    [DBSession setSharedSession:session];
    DBRestClient* restClient = [[DBRestClient alloc] initWithSession:session];
    [restClient loadAccountInfo];
    
    // store the display name from the account
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[restClient valueForKey:@"DropboxDisplayName"]];
    
    // clean up
    [restClient release];
    [session release];
}

- (BOOL)isAccountLinked
{
    // set up the session, we are using the app folder
    DBSession *session = [[DBSession alloc] initWithAppKey:oauthConsumerKey appSecret:oauthConsumerSecretKey root:kDBRootDropbox];
    BOOL isLinked = [session isLinked];
    [session release];
    
    return isLinked;
}

- (void)unlinkAccount
{
    // create the session, must be linked in order to unlink
    DBSession *session = [[DBSession alloc] initWithAppKey:oauthConsumerKey appSecret:oauthConsumerSecretKey root:kDBRootDropbox];
    if (![session isLinked])
    {
        [session release];
        return;
    }
    
    // unlink the account
    [session unlinkAll];
    
    // clean up
    [session release];
}

@end
