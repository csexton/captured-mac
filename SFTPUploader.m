//
//  SFTPUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/11/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "Utilities.h"
#import "SFTPUploader.h"
#import "EMKeychainItem.h"

@implementation SFTPUploader

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
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

- (void)uploadFile:(NSString*)sourceFile
{
    [self performSelectorOnMainThread:@selector(uploadThread:) withObject:sourceFile waitUntilDone:NO];
}

- (void)uploadThread:(NSString*)sourceFile {
	// generate a unique filename
	NSString* tempNam = [Utilities createUniqueFilename:5];
	
	// get host, username and target directory options from user preferences
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* host = [defaults stringForKey:@"SFTPHost"];
	NSString* username = [defaults stringForKey:@"SFTPUser"];
	NSString* targetDir = [Utilities removeAnyTrailingSlashes:[defaults stringForKey:@"SFTPPath"]];
	NSString* imageUrl = [Utilities removeAnyTrailingSlashes:[defaults stringForKey:@"SFTPURL"]];
	NSString* publicKeyFile = [defaults stringForKey:@"SFTPPublicKeyFile"];
	NSString* privateKeyFile = [defaults stringForKey:@"SFTPPrivateKeyFile"];
	NSString* keyPassword = [defaults stringForKey:@"SFTPKeyPassword"];
    
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

	imageUrl = [NSString stringWithFormat:@"%@/%@", imageUrl, tempNam];

	// reset the handle
    CURL* handle = curl_easy_init();
	
	// capture messages in a user-friendly format
	char buf[CURL_ERROR_SIZE];
	curl_easy_setopt(handle, CURLOPT_ERRORBUFFER, buf);
	
	// set the types of authentication that we are going to allow
	curl_easy_setopt(handle, CURLOPT_SSH_AUTH_TYPES, CURLSSH_AUTH_PASSWORD | CURLSSH_AUTH_PUBLICKEY);
	
	// set the curl options
	curl_easy_setopt(handle, CURLOPT_URL, [url cStringUsingEncoding:NSASCIIStringEncoding]);
	curl_easy_setopt(handle, CURLOPT_USERNAME, [username cStringUsingEncoding:NSASCIIStringEncoding]);
	if (password)
		curl_easy_setopt(handle, CURLOPT_PASSWORD, [password cStringUsingEncoding:NSASCIIStringEncoding]);
    curl_easy_setopt(handle, CURLOPT_SSH_PUBLIC_KEYFILE, [publicKeyFile cStringUsingEncoding:NSASCIIStringEncoding]);
    curl_easy_setopt(handle, CURLOPT_SSH_PRIVATE_KEYFILE, [privateKeyFile cStringUsingEncoding:NSASCIIStringEncoding]);
    if (keyPassword)
		curl_easy_setopt(handle, CURLOPT_KEYPASSWD, [keyPassword cStringUsingEncoding:NSASCIIStringEncoding]);
	curl_easy_setopt(handle, CURLOPT_UPLOAD, 1);
	FILE* fp = fopen([sourceFile cStringUsingEncoding:NSASCIIStringEncoding], "rb");
	curl_easy_setopt(handle, CURLOPT_READDATA, fp);
    curl_easy_setopt(handle, CURLOPT_TIMEOUT, 30);

	// do the upload
	[self uploadStarted];
	CURLcode rc = curl_easy_perform(handle);
	fclose(fp);
	curl_easy_cleanup(handle);
	if (rc == CURLE_OK)
	{
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"SFTP", @"Type",
							  imageUrl, @"ImageURL",
							  @"", @"DeleteImageURL",
							  sourceFile, @"FilePath",
							  nil];
		[self uploadSuccess:dict];
	}
	else
	{
		[self uploadFailed:nil];
	}
}

- (NSString*)testConnection
{
	NSString* testResponse = nil;
	
	// get host, username and target directory options from user preferences
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* host = [defaults stringForKey:@"SFTPHost"];
	NSString* username = [defaults stringForKey:@"SFTPUser"];
	NSString* targetDir = [Utilities removeAnyTrailingSlashes:[defaults stringForKey:@"SFTPPath"]];
	NSString* publicKeyFile = [defaults stringForKey:@"SFTPPublicKeyFile"];
	NSString* privateKeyFile = [defaults stringForKey:@"SFTPPrivateKeyFile"];
	NSString* keyPassword = [defaults stringForKey:@"SFTPKeyPassword"];
    
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
    CURL* handle = curl_easy_init();
	
	// capture messages in a user-friendly format
	char buf[CURL_ERROR_SIZE];
	curl_easy_setopt(handle, CURLOPT_ERRORBUFFER, buf);
	
	// set the types of authentication that we are going to allow
	curl_easy_setopt(handle, CURLOPT_SSH_AUTH_TYPES, CURLSSH_AUTH_PASSWORD | CURLSSH_AUTH_PUBLICKEY);
	
	curl_easy_setopt(handle, CURLOPT_URL, [url cStringUsingEncoding:NSASCIIStringEncoding]);
	curl_easy_setopt(handle, CURLOPT_USERNAME, [username cStringUsingEncoding:NSASCIIStringEncoding]);
    if (password)
    	curl_easy_setopt(handle, CURLOPT_PASSWORD, [password cStringUsingEncoding:NSASCIIStringEncoding]);
    curl_easy_setopt(handle, CURLOPT_SSH_PUBLIC_KEYFILE, [publicKeyFile cStringUsingEncoding:NSASCIIStringEncoding]);
    curl_easy_setopt(handle, CURLOPT_SSH_PRIVATE_KEYFILE, [privateKeyFile cStringUsingEncoding:NSASCIIStringEncoding]);
    if (keyPassword)
		curl_easy_setopt(handle, CURLOPT_KEYPASSWD, [keyPassword cStringUsingEncoding:NSASCIIStringEncoding]);
    curl_easy_setopt(handle, CURLOPT_TIMEOUT, 10);

	CURLcode rc = curl_easy_perform(handle);
	curl_easy_cleanup(handle);
	if (rc != CURLE_OK)
		testResponse = [NSString stringWithFormat:@"Error: %s", buf];
	
	return testResponse;
}

@end
