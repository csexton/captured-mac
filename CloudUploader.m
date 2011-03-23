//
//  CloudUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>

#import "UrlShortener.h"
#import "CloudUploader.h"

static char base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation CloudUploader

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

- (NSInteger)uploadFile:(NSString*)sourceFile
{
	// first thing we do is make sure we have a file to read
	FILE* fp = fopen([sourceFile UTF8String], "rb");
	if (fp == NULL)
		return -1;
	
	// generate a unique filename
	char tempNam[16];
	strcpy(tempNam, "XXXXX.png");
	mkstemps(tempNam, 4);
	
	// get the aws keys and bucket name from the defaults
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* bucket = [defaults stringForKey:@"S3URL"];
	NSString* accessKey = [defaults stringForKey:@"S3AccessKey"];
	NSString* secretKey = [defaults stringForKey:@"S3SecretKey" ];
	
	// format the url
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://s3.amazonaws.com/%@/%s", bucket, tempNam]];

	// create the request object
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"PUT"];
	NSInputStream* fileStream = [NSInputStream inputStreamWithFileAtPath:sourceFile];
	[request setHTTPBodyStream:fileStream];

	// build up the data to sign
	NSString* httpVerb = @"PUT";
	NSString* contentType = @"image/png";
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH:mm:ss 'GMT'"];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
	[dateFormatter setTimeZone:timeZone];
	NSString* timestamp = [dateFormatter stringFromDate:[NSDate date]];
	NSString* stringToSign = [NSString stringWithFormat:@"%@\n\n%@\n%@\nx-amz-acl:public-read\nx-amz-storage-class:REDUCED_REDUNDANCY\n", httpVerb, contentType, timestamp];
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
	[request addValue:[NSString stringWithFormat:@"AWS %@:%@", accessKey, base64String] forHTTPHeaderField:@"Authorization"];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request addValue:timestamp forHTTPHeaderField:@"Date"];
	[request addValue:@"public-read" forHTTPHeaderField:@"x-amz-acl"];
	[request addValue:@"REDUCED_REDUNDANCY" forHTTPHeaderField:@"x-amz-storage-class"];
	unsigned long long fileSize = [[[[[[NSFileManager alloc] init] autorelease] attributesOfItemAtPath:sourceFile error:nil] objectForKey:NSFileSize] unsignedLongLongValue];
	[request addValue:[NSString stringWithFormat:@"%llu", fileSize] forHTTPHeaderField:@"Content-Length"];
	
	// do the upload
	NSURLResponse* response;
	NSError* error;
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (error)
		NSLog(@"Error while uploading to cloud provider: %@", [error description]);
	
	return 0;
}

- (NSInteger)testConnection
{
	// get the aws keys and bucket name from the keychain
//	NSString* bucket = @"jvshared";

	// format the url
//	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://s3.amazonaws.com/%@", bucket]];
	
	return 0;
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
