//
//  SFTPUploader.m
//  Captured
//
//  Created by Jorge Velázquez on 3/11/11.
//  Copyright 2011 Christopher Sexton. All rights reserved.
//

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

- (int)uploadFile:(NSString*)sourceFile host:(NSString*)host username:(NSString*)username password:(NSString*)password targetDir:(NSString*)targetDir
{
	CURLcode rc = CURLE_OK;
	
	// generate a unique filename
	char tempNam[16];
	strcpy(tempNam, "XXXXX");
	mkstemp(tempNam);
	
	// format the url
	NSString* url = [NSString stringWithFormat:@"sftp://%@/%@/%s", host, targetDir, tempNam];

	// reset the handle
	curl_easy_reset(handle);
	
	// set the url
	rc = curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
	
	// set the username and password
	rc = curl_easy_setopt(handle, CURLOPT_USERNAME, [username UTF8String]);
	rc = curl_easy_setopt(handle, CURLOPT_PASSWORD, [password UTF8String]);
	
	// tell libcurl we're doing an upload
	rc = curl_easy_setopt(handle, CURLOPT_UPLOAD, 1);
	
	// get a FILE* to pass to libcurl
	FILE* fp = fopen([sourceFile UTF8String], "rb");
	if (fp != NULL)
		rc = curl_easy_setopt(handle, CURLOPT_READDATA, fp);
	
	// do the upload
	rc = curl_easy_perform(handle);
	
	fclose(fp);
	
	return rc;
}

@end
