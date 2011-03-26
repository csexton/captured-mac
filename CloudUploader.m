//
//  CloudUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "Utilities.h"
#import "CapturedAppDelegate.h"
#import "CloudUploader.h"

@implementation CloudUploader

- (void)uploadFile:(NSString*)sourceFile
{
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
	NSString* httpVerb = @"PUT";
	[request setHTTPMethod:httpVerb];
	NSInputStream* fileStream = [NSInputStream inputStreamWithFileAtPath:sourceFile];
	[request setHTTPBodyStream:fileStream];

	// build up the data to sign
	NSString* contentType = @"image/png";
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH:mm:ss 'GMT'"];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
	[dateFormatter setTimeZone:timeZone];
	NSString* timestamp = [dateFormatter stringFromDate:[NSDate date]];
	NSString* stringToSign = [NSString stringWithFormat:@"%@\n\n%@\n%@\nx-amz-acl:public-read\nx-amz-storage-class:REDUCED_REDUNDANCY\n", httpVerb, contentType, timestamp];
	stringToSign = [stringToSign stringByAppendingFormat:@"/%@/%s", bucket, tempNam];

	// create the headers
	NSString* base64String = [Utilities getHmacSha1:stringToSign secretKey:secretKey];
	[request addValue:[NSString stringWithFormat:@"AWS %@:%@", accessKey, base64String] forHTTPHeaderField:@"Authorization"];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request addValue:timestamp forHTTPHeaderField:@"Date"];
	[request addValue:@"public-read" forHTTPHeaderField:@"x-amz-acl"];
	[request addValue:@"REDUCED_REDUNDANCY" forHTTPHeaderField:@"x-amz-storage-class"];
	unsigned long long fileSize = [[[[[[NSFileManager alloc] init] autorelease] attributesOfItemAtPath:sourceFile error:nil] objectForKey:NSFileSize] unsignedLongLongValue];
	[request addValue:[NSString stringWithFormat:@"%llu", fileSize] forHTTPHeaderField:@"Content-Length"];
	
	// do the upload
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
	[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] statusProcessing];
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString* textResponse = [NSString stringWithUTF8String:[data bytes]];
	if (error)
	{
		[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadFailure];
		NSLog(@"Error while uploading to cloud provider: %@", error);
	}
	else if ([response statusCode] != 200)
	{
		[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadFailure];
		NSXMLDocument* doc = [[[NSXMLDocument alloc] init] autorelease];
		[doc initWithXMLString:textResponse options:NSXMLDocumentTidyXML error:&error];
		if (!error)
		{
			NSArray* nodes = [doc nodesForXPath:@"/Error/Code" error:&error];
			if (!error && [nodes count] > 0)
				NSLog(@"Failed to upload file with error: %@", [[nodes objectAtIndex:0] stringValue]);
			else
				NSLog(@"Failed to upload file with HTTP status code %ld", [response statusCode]);
		}
		else
			NSLog(@"Failed to upload file with HTTP status code %ld", [response statusCode]);
	}
	else
	{
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"CloudProvider", @"Type",
							  [url absoluteString] , @"ImageURL",
							  @"", @"DeleteImageURL",
							  sourceFile, @"FilePath",
							  nil];
		[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadSuccess:dict];
	}
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
