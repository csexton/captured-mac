//
//  S3Uploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>

#import "S3Uploader.h"

static char base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation S3Uploader

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
	
	// get the aws keys and bucket name from the keychain
	NSString* bucket = @"jvshared";
	NSString* accessKey = @"0975GDRPMF0HZWXJK702";
	NSString* secretKey = @"i3aLgYHk3Oo8d3/3NJXUjNlLryqdoGNyerYCBbna";
	
	// format the url
	NSString* url = [NSString stringWithFormat:@"https://s3.amazonaws.com/%@/%s", bucket, tempNam];

	// reset the handle
	curl_easy_reset(handle);
	
	// set the url
	rc = curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
	if (rc != CURLE_OK)
	{
		fclose(fp);
		return rc;
	}
	
	// tell libcurl we're doing an upload
	rc = curl_easy_setopt(handle, CURLOPT_VERBOSE, 1);
	rc = curl_easy_setopt(handle, CURLOPT_UPLOAD, 1);
	if (rc != CURLE_OK)
	{
		fclose(fp);
		return rc;
	}
	
	// get a FILE* to pass to libcurl
	rc = curl_easy_setopt(handle, CURLOPT_READDATA, fp);
	if (rc != CURLE_OK)
	{
		fclose(fp);
		return rc;
	}
	
	// calculate the md5 of the file
	unsigned char md5[CC_MD5_DIGEST_LENGTH];
	CC_MD5_CTX md5_context;
	CC_MD5_Init(&md5_context);
	unsigned int size = 0;
	NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:sourceFile];
	while (true)
	{
		NSData* block = [fileHandle readDataOfLength:1024];
		size += [block length];
		if ([block length] > 0)
			CC_MD5_Update(&md5_context, [block bytes], [block length]);
		else
			break;
	}
	CC_MD5_Final(md5, &md5_context);
	NSString* contentMd5 = @"";
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		contentMd5 = [contentMd5 stringByAppendingFormat:@"%02x", md5[i]];
	
	// set the size
	rc = curl_easy_setopt(handle, CURLOPT_INFILESIZE, size);
	if (rc != CURLE_OK)
	{
		fclose(fp);
		return rc;
	}
	
	// get base64 encoding of the md5
	NSString* base64md5 = [[NSData dataWithBytes:md5 length:CC_MD5_DIGEST_LENGTH] base64EncodedString];

	// build up the data to sign
	NSString* httpVerb = @"PUT";
	NSString* contentType = @"image/png";
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH:mm:ss 'GMT'"];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
	[dateFormatter setTimeZone:timeZone];
	NSString* timestamp = [dateFormatter stringFromDate:[NSDate date]];
	NSString* stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\nx-amz-acl:public-read\n", httpVerb, base64md5, contentType, timestamp];
	stringToSign = [stringToSign stringByAppendingFormat:@"/%@/%s", bucket, tempNam];
	NSData* dataToSign = [stringToSign dataUsingEncoding:NSASCIIStringEncoding];

	// create the signature
	CCHmacContext context;
	const char *keyCString = [secretKey cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned char digestRaw[CC_SHA1_DIGEST_LENGTH];
	CCHmacInit(&context, kCCHmacAlgSHA1, keyCString, strlen(keyCString));
	CCHmacUpdate(&context, [dataToSign bytes], [dataToSign length]);
	CCHmacFinal(&context, digestRaw);
	NSData *digestData = [NSData dataWithBytes:digestRaw length:CC_SHA1_DIGEST_LENGTH];
	
	// create the headers
	NSString* base64String = [digestData base64EncodedString];
	NSString* authHeader = [NSString stringWithFormat:@"Authorization: AWS %@:%@", accessKey, base64String];
	NSString* contentMd5Header = [NSString stringWithFormat:@"Content-MD5: %@", base64md5];
	NSString* contentTypeHeader = [NSString stringWithFormat:@"Content-Type: %@", contentType];
	NSString* dateHeader = [NSString stringWithFormat:@"Date: %@", timestamp];
	
	// add the custom headers
	struct curl_slist *slist= NULL;
	slist = curl_slist_append(slist, [contentMd5Header UTF8String]);
	slist = curl_slist_append(slist, [contentTypeHeader UTF8String]);
	slist = curl_slist_append(slist, [dateHeader UTF8String]);
	slist = curl_slist_append(slist, [authHeader UTF8String]);
	slist = curl_slist_append(slist, "x-amz-acl: public-read");
	curl_easy_setopt(handle, CURLOPT_HTTPHEADER, slist);
	
	// do the upload
	rc = curl_easy_perform(handle);
	if (rc == CURLE_OK)
	{
		curl_slist_free_all(slist);
		long response_code;
		rc = curl_easy_getinfo(handle, CURLINFO_RESPONSE_CODE, &response_code);
		if (rc == CURLE_OK && response_code == 200)
			NSLog(@"File successfully uploaded to S3 and accessible at %@", url);
	}
	
	fclose(fp);
	
	return rc;
}

- (NSInteger)testConnection
{
	CURLcode rc = CURLE_OK;
	
	// get the aws keys and bucket name from the keychain
	NSString* bucket = @"jvshared";

	// format the url
	NSString* url = [NSString stringWithFormat:@"https://s3.amazonaws.com/%@", bucket];
	
	curl_easy_reset(handle);
	
	rc = curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
	if (rc != CURLE_OK)
		return rc;
	
	rc = curl_easy_perform(handle);
	
	return rc;
}

@end

@implementation NSData (WithBase64)

- (NSString *) base64EncodedString
{
	NSMutableString *result;
	unsigned char   *raw;
	unsigned long length;
	short i, nCharsToWrite;
	long cursor;
	unsigned char inbytes[3], outbytes[4];
	
	length = [self length];
	
	if (length < 1)
		return @"";
	
	result = [NSMutableString stringWithCapacity:length];
	raw = (unsigned char *)[self bytes];
	
	// Take 3 chars at a time, and encode to 4
	for (cursor = 0; cursor < length; cursor += 3) {
		
		for (i = 0; i < 3; i++) {
			if (cursor + i < length) 
				inbytes[i] = raw[cursor + i];
			else 
				inbytes[i] = 0;
		}
		
		outbytes[0] = (inbytes[0] & 0xFC) >> 2;
		outbytes[1] = ((inbytes[0] & 0x03) << 4) | ((inbytes[1] & 0xF0) >> 4);
		outbytes[2] = ((inbytes[1] & 0x0F) << 2) | ((inbytes[2] & 0xC0) >> 6);
		outbytes[3] = inbytes[2] & 0x3F;
		
		nCharsToWrite = 4;
		
		switch (length - cursor) {
			case 1:
				nCharsToWrite = 2;
				break;
			case 2:
				nCharsToWrite = 3;
				break;
		}
		
		for (i = 0; i < nCharsToWrite; i++) {
			[result appendFormat:@"%c", base64EncodingTable[outbytes[i]]];
		}
		
		for (i = nCharsToWrite; i<4; i++) {
			[result appendString:@"="];
		}
	}
	
	return [NSString stringWithString:result]; // convert to immutable string
}

@end
