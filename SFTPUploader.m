//
//  SFTPUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/11/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "Utilities.h"
#import "CapturedAppDelegate.h"
#import "SFTPUploader.h"
#import "EMKeychainItem.h"

@implementation SFTPUploader

- (id)init
{
    self = [super init];
    if (self) {
		handle = curl_easy_init();
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
	curl_easy_cleanup(handle);
}

- (NSString*)formatPath: (NSString*) targetDir
{
    NSString* url = @"";
    if (targetDir && [targetDir length] > 0) {
        switch ([targetDir characterAtIndex:0]) {
            case '/':
                url = [url stringByAppendingFormat:@"%@/", targetDir];
                break;
                
            case '~':
                url = [url stringByAppendingFormat:@"/%@/", targetDir];
                break;
                
            default:
                url = [url stringByAppendingFormat:@"/~/%@/", targetDir];
                break;
        }
    } else {
        // Use the home directory
        url = [NSString stringWithFormat:@"%@/~/", url];
    }
    return url;
}

- (NSString*)removeAnyTrailingSlashes: (NSString*)str
{
    if( [str hasSuffix: @"/"] )	// Remove any trailing slashes that might screw up removal.    
      str = [str substringToIndex:[str length] - 1];
    return str;
}

- (void)uploadFile:(NSString*)sourceFile
{
	// generate a unique filename
	NSString* tempNam = [Utilities createUniqueFilename];
	
	// get host, username and target directory options from user preferences
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* host = [defaults stringForKey:@"SFTPHost"];
	NSString* username = [defaults stringForKey:@"SFTPUser"];
	NSString* targetDir = [self removeAnyTrailingSlashes:[defaults stringForKey:@"SFTPPath"]];
	NSString* uploadUrl = [self removeAnyTrailingSlashes:[defaults stringForKey:@"SFTPURL"]];
        
    // get the password from the keychain
    NSString* password = nil;
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured SFTP" withUsername:@""];
    if (keychainItem){
        password = keychainItem.password;
    } else {
        NSLog(@"No password found for SFTP User '%@' in the keychain", username);
    }

	// format the urls
	NSString* url = [NSString stringWithFormat:@"sftp://%@%@%@", host, [self formatPath:targetDir], tempNam];

	uploadUrl = [NSString stringWithFormat:@"%@/%@", uploadUrl, tempNam];

	// reset the handle
	curl_easy_reset(handle);
	
	// capture messages in a user-friendly format
	char buf[CURL_ERROR_SIZE];
	curl_easy_setopt(handle, CURLOPT_ERRORBUFFER, buf);
	
	// allow only password auth for now
	curl_easy_setopt(handle, CURLOPT_SSH_AUTH_TYPES, CURLSSH_AUTH_PASSWORD);
	
	// set the curl options
	curl_easy_setopt(handle, CURLOPT_URL, [url cStringUsingEncoding:NSASCIIStringEncoding]);
	curl_easy_setopt(handle, CURLOPT_USERNAME, [username cStringUsingEncoding:NSASCIIStringEncoding]);
	if (password)
		curl_easy_setopt(handle, CURLOPT_PASSWORD, [password cStringUsingEncoding:NSASCIIStringEncoding]);
	curl_easy_setopt(handle, CURLOPT_UPLOAD, 1);
	FILE* fp = fopen([sourceFile cStringUsingEncoding:NSASCIIStringEncoding], "rb");
	curl_easy_setopt(handle, CURLOPT_READDATA, fp);

	// do the upload
	[AppDelegate statusProcessing];
	CURLcode rc = curl_easy_perform(handle);
	if (rc == CURLE_OK)
	{
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"SFTP", @"Type",
							  uploadUrl, @"ImageURL",
							  @"", @"DeleteImageURL",
							  sourceFile, @"FilePath",
							  nil];
		[AppDelegate uploadSuccess:dict];
	}
	else
	{
		[AppDelegate uploadFailure];
	}
}

- (NSString*)testConnection
{
	NSString* testResponse = nil;
	
	// get host, username and target directory options from user preferences
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* host = [defaults stringForKey:@"SFTPHost"];
	NSString* username = [defaults stringForKey:@"SFTPUser"];
	NSString* targetDir = [self removeAnyTrailingSlashes:[defaults stringForKey:@"SFTPPath"]];
    
    // FIXME: Duplicate code
    // get the password from the keychain
    NSString* password = nil;
    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"Captured SFTP" withUsername:@""];
    if (keychainItem){
        password = keychainItem.password;
    } else {
        NSLog(@"No password found for SFTP User '%@' in the keychain", username);
    }

	// set the url to just do an ls of the target dir
    NSString* url = [NSString stringWithFormat:@"sftp://%@%@", host, [self formatPath:targetDir]];

	
	// reset the curl handle
	curl_easy_reset(handle);
	
	// capture messages in a user-friendly format
	char buf[CURL_ERROR_SIZE];
	curl_easy_setopt(handle, CURLOPT_ERRORBUFFER, buf);
	
	// allow only password auth for now
	curl_easy_setopt(handle, CURLOPT_SSH_AUTH_TYPES, CURLSSH_AUTH_PASSWORD);
	
	curl_easy_setopt(handle, CURLOPT_URL, [url cStringUsingEncoding:NSASCIIStringEncoding]);
	curl_easy_setopt(handle, CURLOPT_USERNAME, [username cStringUsingEncoding:NSASCIIStringEncoding]);
	curl_easy_setopt(handle, CURLOPT_PASSWORD, [password cStringUsingEncoding:NSASCIIStringEncoding]);

	CURLcode rc = curl_easy_perform(handle);
	if (rc != CURLE_OK)
		testResponse = [NSString stringWithFormat:@"Error: %s", buf];
	
	return testResponse;
}

@end
