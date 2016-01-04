//
//  CloudUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/15/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>

#import "CloudUploader.h"

static char alNum[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
static size_t CHAR_COUNT = 62;
static char base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


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


@implementation CloudUploader

# pragma mark: Imported from Utilities

- (NSString*)removeAnyTrailingSlashes: (NSString*)str {
  if (str) {
    if( [str hasSuffix: @"/"] ){	// Remove any trailing slashes that might screw up removal.
      return [str substringToIndex:[str length] - 1];
    }
  }
  return str;
}

- (NSString*)createUniqueFilename:(NSInteger) numChars {
  char buf[64];
  srand((unsigned int)time(NULL));
  for (int i = 0; i < numChars; i++)
    buf[i] = alNum[rand() % CHAR_COUNT];
  buf[numChars] = 0;
  strcat(buf, ".png");
  return [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
}

- (NSString*)getHmacSha1:(NSString*)stringToSign secretKey:(NSString*)secretKey {
  // create the signature
  CCHmacContext context;
  NSData* dataToSign = [stringToSign dataUsingEncoding:NSASCIIStringEncoding];
  unsigned char digestRaw[CC_SHA1_DIGEST_LENGTH];
  CCHmacInit(&context, kCCHmacAlgSHA1, [secretKey cStringUsingEncoding:NSASCIIStringEncoding], [secretKey length]);
  CCHmacUpdate(&context, [dataToSign bytes], [dataToSign length]);
  CCHmacFinal(&context, digestRaw);
  NSData* digestData = [NSData dataWithBytes:digestRaw length:CC_SHA1_DIGEST_LENGTH];
  return [digestData base64EncodedString];
}

- (NSString*)generateS3TempURL:(NSString*)baseUrl bucketName:(NSString*)bucketName objectName:(NSString*)objectName minutesToExpiration:(NSUInteger)minutesToExpiration {
  NSUInteger expirationTime = time(NULL) + 60 * minutesToExpiration;
  NSString* stringToSign = [NSString stringWithFormat:@"GET\n\n\n%ld\n/%@/%@", (long) expirationTime, bucketName, objectName];
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSString* accessKey = [defaults stringForKey:@"S3AccessKey"];
  NSString* secretKey = [defaults stringForKey:@"S3SecretKey" ];
  NSString* base64String = [self getHmacSha1:stringToSign secretKey:secretKey];
  NSString* url = [NSString stringWithFormat:@"%@?AWSAccessKeyId=%@&Signature=%@&Expires=%ld", baseUrl, accessKey, base64String, (long) expirationTime];
  return url;
}


#pragma mark Callbacks


- (void)uploadFailed:(id)notUsed {
  NSLog(@"Upload Failed");
}

- (void)uploadSuccess:(NSDictionary *)dict {
  NSLog(@"Upload Success: %@", dict);

}


#pragma mark Original Implementaiton

- (void)uploadFile:(NSString*)sourceFile
{
	[self setFilePath:sourceFile];

	// get the aws keys and bucket name from the defaults
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* accessKey = [defaults stringForKey:@"S3AccessKey"];
	NSString* secretKey = [defaults stringForKey:@"S3SecretKey" ];
	NSString* bucket = [defaults stringForKey:@"S3Bucket"];
    NSString* publicUrl = [defaults stringForKey:@"S3URL"];
    NSInteger nameLength = [defaults integerForKey:@"S3FileNameLength"];
	BOOL reducedRedundancy = [defaults boolForKey:@"S3ReducedRedundancyStorage"];
    BOOL privateUpload = [defaults boolForKey:@"S3PrivateUpload"];
    NSInteger minutesToExpiration = [defaults integerForKey:@"S3MinutesToExpiration"];

	// validate the inputs
	if (!accessKey || [accessKey length] == 0 || !secretKey || [secretKey length] == 0 || !bucket || [bucket length] == 0)
	{
		[self uploadFailed:nil];
		return;
	}

	// generate a unique filename
	NSString* tempNam = [self createUniqueFilename:nameLength];

    if (publicUrl) {
        publicUrl = [self removeAnyTrailingSlashes: publicUrl];
        publicUrl = [NSString stringWithFormat:@"%@/%@", publicUrl, tempNam];
    }else {
        publicUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/%@/%@", bucket, tempNam];
    }

    // if this is a private upload, then we need to generate a URL with query params to allow access
    if (privateUpload) {
        publicUrl = [self generateS3TempURL:publicUrl bucketName:bucket objectName:tempNam minutesToExpiration:minutesToExpiration];
    }

    // set the upload url for the response
	[self setUploadUrl:publicUrl];

	// format the url
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://s3.amazonaws.com/%@/%@", bucket, tempNam]];
	[self setDeleteUrl:[url absoluteString]];

	// create the request object
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	NSString* httpVerb = @"PUT";
	[request setHTTPMethod:httpVerb];
	NSInputStream* fileStream = [NSInputStream inputStreamWithFileAtPath:sourceFile];
	[request setHTTPBodyStream:fileStream];

	// build up the data to sign
	NSString* contentType = @"image/png";
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH:mm:ss 'GMT'"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
	[dateFormatter setTimeZone:timeZone];
	NSString* timestamp = [dateFormatter stringFromDate:[NSDate date]];
	NSString* stringToSign = [NSString stringWithFormat:@"%@\n\n%@\n%@\n", httpVerb, contentType, timestamp];
    if (!privateUpload) {
        stringToSign = [stringToSign stringByAppendingString:@"x-amz-acl:public-read\n"];
    }
	if (reducedRedundancy) {
		stringToSign = [stringToSign stringByAppendingFormat:@"x-amz-storage-class:REDUCED_REDUNDANCY\n"];
    }
	stringToSign = [stringToSign stringByAppendingFormat:@"/%@/%@", bucket, tempNam];

	// create the headers
	NSString* base64String = [self getHmacSha1:stringToSign secretKey:secretKey];
	[request addValue:[NSString stringWithFormat:@"AWS %@:%@", accessKey, base64String] forHTTPHeaderField:@"Authorization"];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request addValue:timestamp forHTTPHeaderField:@"Date"];
    if (!privateUpload) {
        [request addValue:@"public-read" forHTTPHeaderField:@"x-amz-acl"];
    }
	if (reducedRedundancy) {
		[request addValue:@"REDUCED_REDUNDANCY" forHTTPHeaderField:@"x-amz-storage-class"];
    }
	unsigned long long fileSize = [[[[[NSFileManager alloc] init] attributesOfItemAtPath:sourceFile error:nil] objectForKey:NSFileSize] unsignedLongLongValue];
	[request addValue:[NSString stringWithFormat:@"%llu", fileSize] forHTTPHeaderField:@"Content-Length"];

	// do the upload
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse* r = (NSHTTPURLResponse*) response;
	if ([r statusCode] != 200)
	{
		[self uploadFailed:nil];
	}
	else
	{
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"CloudProvider", @"Type",
							  self.uploadUrl, @"ImageURL",
							  self.deleteUrl, @"DeleteImageURL",
							  self.filePath, @"FilePath",
							  nil];
		[self uploadSuccess:dict];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSString* textResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (textResponse) {
		NSError* error = nil;
		NSXMLDocument* doc = [[NSXMLDocument alloc] initWithXMLString:textResponse options:NSXMLDocumentTidyXML error:&error];
		if (!error)
		{
			NSArray* nodes = [doc nodesForXPath:@"/Error/Message" error:&error];
			if (!error && [nodes count] > 0)
				NSLog(@"Failed to upload file with error: %@", [[nodes objectAtIndex:0] stringValue]);
		}
    else {
			NSLog(@"Failed to parse response: %@", error);
    }
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self uploadFailed:nil];
	NSLog(@"Error while uploading to cloud provider: %@", error);
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
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH:mm:ss 'GMT'"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
	[dateFormatter setTimeZone:timeZone];
	NSString* timestamp = [dateFormatter stringFromDate:[NSDate date]];
	NSString* stringToSign = [NSString stringWithFormat:@"%@\n\n\n%@\n", httpVerb, timestamp];
	stringToSign = [stringToSign stringByAppendingFormat:@"/%@", bucket];

	// create the headers
	NSString* base64String = [self getHmacSha1:stringToSign secretKey:secretKey];
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
			}
			else
				testResponse = [NSString stringWithFormat:@"Failed with HTTP status code %ld", [response statusCode]];
		}
		else
			testResponse = [NSString stringWithFormat:@"Failed with HTTP status code %ld", [response statusCode]];
	}

	return testResponse;
}

@end
