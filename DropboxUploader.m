//
//  DropboxUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "Utilities.h"
#import "JSON/JSON.h"
#import "DropboxUploader.h"

// these are the Dropbox API keys, keep them safe
static NSString* oauthConsumerKey = @"4zwv9noh6qesnob";
static NSString* oauthConsumerSecretKey = @"folukm6dwd1l93r";

@implementation DropboxUploader

- (void)uploadFile:(NSString*)sourceFile
{
	[self setFilePath:sourceFile];
	
	// get the token
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* token = [defaults stringForKey:@"DropboxToken"];
	NSString* secret = [defaults stringForKey:@"DropboxSecret"];
	NSString* folder = [defaults stringForKey:@"DropboxDirName"];
	
	// must have both of these before we can proceed
	if (!token || [token length] == 0 || !secret || [secret length] == 0)
	{
		[self uploadFailed:nil];
		return;
	}
	
	// generate a unique filename
	NSString* tempNam = [Utilities createUniqueFilename:5];
	
	// set up the url
	NSString* uploadPath = @"https://api-content.dropbox.com/0/files/dropbox/Public/";
	if (folder)
		uploadPath = [uploadPath stringByAppendingString:folder];
	while ([uploadPath rangeOfString:@"//" options:0 range:NSMakeRange(8, [uploadPath length] - 8)].location != NSNotFound)
		uploadPath = [uploadPath stringByReplacingOccurrencesOfString:@"//" withString:@"/" options:0 range:NSMakeRange(8, [uploadPath length] - 8)];
	NSURL* url = [NSURL URLWithString:uploadPath];
	
	// now the request
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
	NSString* httpVerb = @"POST";
	[request setHTTPMethod:httpVerb];
	
	// generate a unique nonce for this request
	time_t oauthTimestamp = time(NULL);
	NSString* oauthNonce = [Utilities genRandString];
	
	// format the signature base string
	NSString* sigBaseString = [Utilities genSigBaseString:[url absoluteString] method:@"POST" fileName:tempNam consumerKey:oauthConsumerKey nonce:oauthNonce timestamp:oauthTimestamp token:token];

	// build the signature
	NSString* oauthSignature = [Utilities getHmacSha1:sigBaseString secretKey:[NSString stringWithFormat:@"%@&%@", oauthConsumerSecretKey, secret]];
	
	// set up the body
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString* stringBoundary = (NSString*)CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	NSMutableData* bodyData = [NSMutableData data];
	[bodyData appendData: [[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSASCIIStringEncoding]];

	// Add data to upload
	[bodyData appendData: [[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", tempNam] dataUsingEncoding:NSASCIIStringEncoding]];
	[bodyData appendData: [[NSString stringWithString:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];

	// write the raw file data to the body data
	if ([[NSFileManager defaultManager] fileExistsAtPath:sourceFile]) {
		NSFileHandle* readFile = [NSFileHandle fileHandleForReadingAtPath:sourceFile];
		NSData* readData;
		while ((readData = [readFile readDataOfLength:1024 * 64]) != nil && [readData length] > 0) {
			[bodyData appendData:readData];
		}
		[readFile closeFile];
	} else {
		NSLog(@"unable to open sourceFile");
	}
	
	// write the end boundary to the mime file
	[bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSASCIIStringEncoding]];
	
	// build the custom headers
	NSString* authHeader = [Utilities genAuthHeader:tempNam consumerKey:oauthConsumerKey signature:oauthSignature nonce:oauthNonce timestamp:oauthTimestamp token:token];
	
	// add the custom headers
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
	[request addValue:authHeader forHTTPHeaderField:@"Authorization"];
	[request addValue:[NSString stringWithFormat:@"%lu", [bodyData length]]	forHTTPHeaderField:@"Content-Length"];
	[stringBoundary release];
	
	// set the data
	[request setHTTPBody:bodyData];
	
	// this is the public url
	NSInteger uid = [defaults integerForKey:@"DropboxUID"];
	NSString* publicLink = [NSString stringWithFormat:@"https://dl.dropbox.com/u/%lu/", uid];
	if (folder)
		publicLink = [publicLink stringByAppendingString:folder];
	publicLink = [publicLink stringByAppendingFormat:@"/%@", tempNam];
	while ([publicLink rangeOfString:@"//" options:0 range:NSMakeRange(8, [publicLink length] - 8)].location != NSNotFound)
		publicLink = [publicLink stringByReplacingOccurrencesOfString:@"//" withString:@"/" options:0 range:NSMakeRange(8, [publicLink length] - 8)];
	[self setUploadUrl:publicLink];
	
	// now set the delete url
	[self setDeleteUrl:[NSString stringWithFormat:@"https://api.dropbox.com/0/fileops/delete?root=dropbox&path=%@", [Utilities URLEncode:[NSString stringWithFormat:@"/Public/Captured/%s", tempNam]]]];

	// do the upload
	[self uploadStarted];
	[NSURLConnection connectionWithRequest:request delegate:self];
	[request release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse* r = (NSHTTPURLResponse*) response;
	if ([r statusCode] != 200)
	{
		if ([r statusCode] == 401)
		{
			// this means the token has expired (unlikely, since it is given out for 10 years) or revoked, which means
			// we need to re-authenticate, so we should wipe out the stored token since it's no longer valid
			[self unlinkAccount];
		}
		[self uploadFailed:nil];
		NSLog(@"Upload failed with HTTP status code %ld", [r statusCode]);
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSString* textResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString* result = [[textResponse JSONValue] valueForKey:@"result"];
	if ([result isEqualToString:@"winner!"])
	{
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"DropboxProvider", @"Type",
							  uploadUrl, @"ImageURL",
							  deleteUrl, @"DeleteImageURL",
							  filePath, @"FilePath",
							  nil];
		[self uploadSuccess:dict];
	}
	else
	{
		[self uploadFailed:nil];
		NSLog(@"Upload failed with error message %@", result);
	}
	[textResponse release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self uploadFailed:nil];
	NSLog(@"Error while uploading to Dropbox: %@", error);
}

- (NSString*)linkAccount:(NSString*)email password:(NSString*)password {
	NSString* linkResponse = nil;
	
	// create the url and request
	NSURL* url = [NSURL URLWithString:@"https://api.dropbox.com/0/token"];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	
	// timestamp and nonce generation
	time_t timestamp = time(NULL);
	NSString* nonce = [Utilities genRandString];
	
	// format the signature base string
	NSString* sigBaseString = [Utilities genSigBaseString:[url absoluteString] method:@"POST" fileName:nil consumerKey:oauthConsumerKey nonce:nonce timestamp:timestamp token:nil];
	
	// build the signature
	NSString* oauthSignature = [Utilities getHmacSha1:sigBaseString secretKey:oauthConsumerSecretKey];
	[sigBaseString release];
	
	// build the authentication header
	NSString* authHeader = [Utilities genAuthHeader:nil consumerKey:oauthConsumerKey signature:oauthSignature nonce:nonce timestamp:timestamp token:nil];
	
	// add the post data
	NSString* paramsString = [NSString stringWithFormat:@"email=%@&password=%@", [Utilities URLEncode:email], [Utilities URLEncode:password]];
	NSData* paramsData = [paramsString dataUsingEncoding:NSASCIIStringEncoding];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:paramsData];
	
	// add the headers
	[request addValue:authHeader forHTTPHeaderField:@"Authorization"];
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request addValue:[NSString stringWithFormat:@"%lu", [paramsData length]] forHTTPHeaderField:@"Content-Length"];
	
	// make the request
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

	// parse out the response
	if (error)
	{
		linkResponse = [NSString stringWithFormat:@"Error calling Dropbox API: %@", [error description]];
	}
	else if ([response statusCode] != 200)
	{
		NSString* textResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSDictionary* dict = [textResponse JSONValue];
		linkResponse = [NSString stringWithFormat:@"%@", [dict valueForKey:@"error"]];
		[textResponse release];
	}
	else
	{
		// get the new token and secret
		NSString* textResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSDictionary* dict = [textResponse JSONValue];
		NSString* newToken = [dict valueForKey:@"token"];
		NSString* newSecret = [dict valueForKey:@"secret"];
		
		// store there in user defaults, may want to move them elsewhere at some point
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:newToken forKey:@"DropboxToken"];
		[defaults setValue:newSecret forKey:@"DropboxSecret"];
		
		// done with the string
		[textResponse release];
		
		// now we get the account info, we'll need the user id for formatting the upload links
		[self getAccountInfo];
	}
	
	return linkResponse;
}

- (void)getAccountInfo {
	// URL for this request
	NSURL* url = [NSURL URLWithString:@"https://api.dropbox.com/0/account/info"];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	
	// timestamp and nonce generation
	time_t timestamp = time(NULL);
	NSString* nonce = [Utilities genRandString];
	
	// get the user settings
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* token = [defaults stringForKey:@"DropboxToken"];
	NSString* secret = [defaults stringForKey:@"DropboxSecret"];
	
	// generate oauth signature
	NSString* sigBaseString = [Utilities genSigBaseString:[url absoluteString] method:@"GET" fileName:nil consumerKey:oauthConsumerKey nonce:nonce timestamp:timestamp token:token];
	NSString* oauthSignature = [Utilities getHmacSha1:sigBaseString secretKey:[NSString stringWithFormat:@"%@&%@", oauthConsumerSecretKey, secret]];
	[sigBaseString release];
	
	// build the custom headers
	NSString* authHeader = [Utilities genAuthHeader:nil consumerKey:oauthConsumerKey signature:oauthSignature nonce:nonce timestamp:timestamp token:token];
	
	// add the custom headers
	[request addValue:authHeader forHTTPHeaderField:@"Authorization"];

	// make the request
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString* textResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (error)
	{
		NSLog(@"Error while attempting to get account info: %@", [error description]);
	}
	else if ([response statusCode] != 200)
	{
		NSDictionary* dict = [textResponse JSONValue];
		NSString* errorString = [dict valueForKey:@"error"];
		NSLog(@"Error while attempting to get Dropbox account info, HTTP status code %lu, message: %@", [response statusCode], errorString);
	}
	else
	{
		// grab the bits that we want to save
		NSDictionary* dict = [textResponse JSONValue];
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		[defaults setInteger:[[dict valueForKey:@"uid"] unsignedLongValue] forKey:@"DropboxUID"];
		[defaults setValue:[dict valueForKey:@"display_name"] forKey:@"DropboxDisplayName"];
		[defaults setValue:[dict valueForKey:@"email"] forKey:@"DropboxEmail"];
	}
	[textResponse release];
}

- (BOOL)isAccountLinked
{
	// account is linked if we have a token/secret pair
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* displayName = [defaults stringForKey:@"DropboxDisplayName"];
	
	return (displayName && [displayName length] > 0);
}

- (void)unlinkAccount
{
	// remove the dropbox token from our records
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"DropboxToken"];
	[defaults removeObjectForKey:@"DropboxSecret"];
	[defaults removeObjectForKey:@"DropboxUID"];
	[defaults removeObjectForKey:@"DropboxDisplayName"];
	[defaults removeObjectForKey:@"DropboxEmail"];
}

@end
