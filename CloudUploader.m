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
	// get the aws keys and bucket name from the defaults
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* accessKey = [defaults stringForKey:@"S3AccessKey"];
	NSString* secretKey = [defaults stringForKey:@"S3SecretKey" ];
	NSString* bucket = [defaults stringForKey:@"S3Bucket"];
    NSString* publicUrl = [defaults stringForKey:@"S3URL"];

	BOOL reducedRedundancy = [defaults boolForKey:@"S3ReducedRedundancyStorage"];
	
	// validate the inputs
	if (!accessKey || [accessKey length] == 0 || !secretKey || [secretKey length] == 0 || !bucket || [bucket length] == 0)
	{
		[AppDelegate uploadFailure];
		return;
	}
	
	// generate a unique filename
	NSString* tempNam = [Utilities createUniqueFilename];
    
    if (publicUrl) {
        publicUrl = [Utilities removeAnyTrailingSlashes: publicUrl];
        publicUrl = [NSString stringWithFormat:@"%@/%@", publicUrl, tempNam];
    }else {
        publicUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/%@/%@", bucket, tempNam];
    }
	
	// format the url
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://s3.amazonaws.com/%@/%@", bucket, tempNam]];

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
	NSString* stringToSign = [NSString stringWithFormat:@"%@\n\n%@\n%@\nx-amz-acl:public-read\n", httpVerb, contentType, timestamp];
	if (reducedRedundancy)
		stringToSign = [stringToSign stringByAppendingFormat:@"x-amz-storage-class:REDUCED_REDUNDANCY\n"];
	stringToSign = [stringToSign stringByAppendingFormat:@"/%@/%@", bucket, tempNam];

	// create the headers
	NSString* base64String = [Utilities getHmacSha1:stringToSign secretKey:secretKey];
	[request addValue:[NSString stringWithFormat:@"AWS %@:%@", accessKey, base64String] forHTTPHeaderField:@"Authorization"];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request addValue:timestamp forHTTPHeaderField:@"Date"];
	[request addValue:@"public-read" forHTTPHeaderField:@"x-amz-acl"];
	if (reducedRedundancy)
		[request addValue:@"REDUCED_REDUNDANCY" forHTTPHeaderField:@"x-amz-storage-class"];
	unsigned long long fileSize = [[[[[[NSFileManager alloc] init] autorelease] attributesOfItemAtPath:sourceFile error:nil] objectForKey:NSFileSize] unsignedLongLongValue];
	[request addValue:[NSString stringWithFormat:@"%llu", fileSize] forHTTPHeaderField:@"Content-Length"];
	
	// do the upload
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
	[AppDelegate statusProcessing];
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (error)
	{
		[AppDelegate uploadFailure];
		NSLog(@"Error while uploading to cloud provider: %@", error);
	}
	else if ([response statusCode] != 200)
	{
		[AppDelegate uploadFailure];
		if (data && [data length] > 0)
		{
			NSString* textResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if (textResponse) {
				NSXMLDocument* doc = [[NSXMLDocument alloc] initWithXMLString:textResponse options:NSXMLDocumentTidyXML error:&error];
				if (!error)
				{
					NSArray* nodes = [doc nodesForXPath:@"/Error/Message" error:&error];
					if (!error && [nodes count] > 0)
						NSLog(@"Failed to upload file with error: %@", [[nodes objectAtIndex:0] stringValue]);
					else
						NSLog(@"Failed to upload file with HTTP status code %d", [response statusCode]);
				}
				else
					NSLog(@"Failed to upload file with HTTP status code %d", [response statusCode]);
				[doc release];
			}
			else
			{
				NSLog(@"Failed to upload file with HTTP status code %d", [response statusCode]);
			}
			[textResponse release];
		}
		else
		{
			NSLog(@"Failed to upload file with HTTP status code %d", [response statusCode]);
		}
	}
	else
	{
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"CloudProvider", @"Type",
							  publicUrl , @"ImageURL",
							  [url absoluteString], @"DeleteImageURL",
							  sourceFile, @"FilePath",
							  nil];
		[AppDelegate uploadSuccess:dict];
	}
}

- (NSString*)testConnection
{
	NSString* testResponse = nil;

	// get the aws keys and bucket name from the defaults
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* bucket = [defaults stringForKey:@"S3Bucket"];
	NSString* accessKey = [defaults stringForKey:@"S3AccessKey"];
	NSString* secretKey = [defaults stringForKey:@"S3SecretKey" ];
	
	// format the url
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://s3.amazonaws.com/%@", bucket]];
	
	// create the request object
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	NSString* httpVerb = @"GET";
	[request setHTTPMethod:httpVerb];
	
	// build up the data to sign
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH:mm:ss 'GMT'"];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
	[dateFormatter setTimeZone:timeZone];
	NSString* timestamp = [dateFormatter stringFromDate:[NSDate date]];
	NSString* stringToSign = [NSString stringWithFormat:@"%@\n\n\n%@\n", httpVerb, timestamp];
	stringToSign = [stringToSign stringByAppendingFormat:@"/%@", bucket];
	
	// create the headers
	NSString* base64String = [Utilities getHmacSha1:stringToSign secretKey:secretKey];
	[request addValue:[NSString stringWithFormat:@"AWS %@:%@", accessKey, base64String] forHTTPHeaderField:@"Authorization"];
	[request addValue:timestamp forHTTPHeaderField:@"Date"];
	
	// do the upload
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (error)
	{
		return [NSString stringWithFormat:@"Error while uploading to cloud provider: %@", error];
	}
	else if ([response statusCode] != 200)
	{
		if (data && [data length] > 0)
		{
			NSString* textResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if (textResponse)
			{
				NSXMLDocument* doc = [[NSXMLDocument alloc] initWithXMLString:textResponse options:NSXMLDocumentTidyXML error:&error];
				if (!error)
				{
					NSArray* nodes = [doc nodesForXPath:@"/Error/Message" error:&error];
					if (!error && [nodes count] > 0)
						testResponse = [NSString stringWithFormat:@"Failed with error: %@", [[nodes objectAtIndex:0] stringValue]];
					else
						testResponse = [NSString stringWithFormat:@"Failed with HTTP status code %ld", [response statusCode]];
				}
				else
					testResponse = [NSString stringWithFormat:@"Failed with HTTP status code %ld", [response statusCode]];
				[doc release];
			}
			else
				testResponse = [NSString stringWithFormat:@"Failed with HTTP status code %ld", [response statusCode]];
			[textResponse release];
		}
		else
			testResponse = [NSString stringWithFormat:@"Failed with HTTP status code %ld", [response statusCode]];
	}
	
	return testResponse;
}

@end
