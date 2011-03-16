//
//  DropboxUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "DropboxSDK.h"
#import "DropboxUploader.h"

@implementation DropboxUploader

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

- (NSInteger)uploadFile:(NSString*)sourceFile
{
	CURLcode rc = CURLE_OK;
	
	// first thing we do is make sure we have a file to read
	FILE* fp = fopen([sourceFile UTF8String], "rb");
	if (fp == NULL)
		return -1;
	
	// generate a unique filename
	char tempNam[16];
	strcpy(tempNam, "XXXXX.png");
	mkstemps(tempNam, 4);
		
	// do the upload
	rc = curl_easy_perform(handle);
	if (rc == CURLE_OK)
	{
		long response_code;
		rc = curl_easy_getinfo(handle, CURLINFO_RESPONSE_CODE, &response_code);
		if (rc == CURLE_OK && response_code == 200)
			NSLog(@"File successfully uploaded to Dropbox and accessible at ");
	}
	
	fclose(fp);
	
	return rc;
}

- (NSInteger)testConnection
{
	CURLcode rc = CURLE_OK;
	
	rc = curl_easy_perform(handle);
	
	return rc;
}

@end
