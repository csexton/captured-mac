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

@implementation SFTPUploader

@synthesize handle;

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

- (void)uploadFile:(NSString*)sourceFile
{
	// generate a unique filename
	NSString* tempNam = [Utilities createUniqueFilename];
	
	// get host, username, password and target directory options from user preferences
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* host = [defaults stringForKey:@"SFTPHost"];
	NSString* username = [defaults stringForKey:@"SFTPUser"];
	NSString* password = [defaults stringForKey:@"SFTPPassword"];
	NSString* targetDir = [defaults stringForKey:@"SFTPPath"];
	NSString* uploadUrl = [defaults stringForKey:@"SFTPURL"];
	if ([targetDir length] == 0)
		targetDir = @"~";
	
	// format the urls
	NSString* url = [NSString stringWithFormat:@"sftp://%@/%@/%@", host, targetDir, tempNam];
	uploadUrl = [NSString stringWithFormat:@"%@/%@", uploadUrl, tempNam];

	// reset the handle
	curl_easy_reset(handle);
	
	// capture messages in a user-friendly format
	char buf[CURL_ERROR_SIZE];
	curl_easy_setopt(handle, CURLOPT_ERRORBUFFER, buf);
	
	// set the curl options
	curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
	curl_easy_setopt(handle, CURLOPT_USERNAME, [username UTF8String]);
	curl_easy_setopt(handle, CURLOPT_PASSWORD, [password UTF8String]);
	curl_easy_setopt(handle, CURLOPT_UPLOAD, 1);
	FILE* fp = fopen([sourceFile UTF8String], "rb");
	curl_easy_setopt(handle, CURLOPT_READDATA, fp);

	// do the upload
	[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] statusProcessing];
	CURLcode rc = curl_easy_perform(handle);
	if (rc == CURLE_OK)
	{
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"SFTP", @"Type",
							  uploadUrl, @"ImageURL",
							  @"", @"DeleteImageURL",
							  sourceFile, @"FilePath",
							  nil];
		[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadSuccess:dict];
	}
	else
	{
		[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadFailure];		
	}
}

- (NSInteger)testConnection
{
	CURLcode rc = CURLE_OK;
	
	// get host, username, password and target directory options from user preferences
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* host = [defaults stringForKey:@"SFTPHost"];
	NSString* username = [defaults stringForKey:@"SFTPUser"];
	NSString* password = [defaults stringForKey:@"SFTPPassword"];
	NSString* targetDir = [defaults stringForKey:@"SFTPPath"];
	if ([targetDir length] == 0)
		targetDir = @"~";

	// set the url to just do an ls of the target dir
	NSString* url = [NSString stringWithFormat:@"sftp://%@/%@", host, targetDir];
	
	// reset the curl handle
	curl_easy_reset(handle);
	
	// capture messages in a user-friendly format
	char buf[CURL_ERROR_SIZE];
	curl_easy_setopt(handle, CURLOPT_ERRORBUFFER, buf);
	
	rc = curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
	if (rc != CURLE_OK)
		return rc;
	
	rc = curl_easy_setopt(handle, CURLOPT_USERNAME, [username UTF8String]);
	if (rc != CURLE_OK)
		return rc;
	rc = curl_easy_setopt(handle, CURLOPT_PASSWORD, [password UTF8String]);
	if (rc != CURLE_OK)
		return rc;

	rc = curl_easy_perform(handle);
	
	return rc;
}

@end
