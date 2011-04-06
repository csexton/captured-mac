//
//  DropboxUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "Utilities.h"
#import "JSON/JSON.h"
#import "CapturedAppDelegate.h"
#import "DropboxUploader.h"

// these are the Dropbox API keys, keep them safe
static NSString* oauthConsumerKey = @"4zwv9noh6qesnob";
static NSString* oauthConsumerSecretKey = @"folukm6dwd1l93r";

@implementation DropboxUploader

- (void)uploadFile:(NSString*)sourceFile
{
	// get the token
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* token = [defaults stringForKey:@"DropboxToken"];
	NSString* secret = [defaults stringForKey:@"DropboxSecret"];
	
	// must have both of these before we can proceed
	if (!token || [token length] == 0 || !secret || [secret length] == 0)
	{
		[AppDelegate uploadFailure];
		return;
	}
	
	// generate a unique filename
	NSString* tempNam = [Utilities createUniqueFilename];
	
	// set up the url
	NSURL* url = [NSURL URLWithString:@"https://api-content.dropbox.com/0/files/dropbox/Public/Captured"];
	
	// now the request
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	NSString* httpVerb = @"POST";
	[request setHTTPMethod:httpVerb];
	
	// generate a unique nonce for this request
	time_t oauthTimestamp = time(NULL);
	NSString* oauthNonce = [self genRandString];
	
	// format the signature base string
	NSString* sigBaseString = [self genSigBaseString:[url absoluteString] method:@"POST" fileName:tempNam consumerKey:oauthConsumerKey nonce:oauthNonce timestamp:oauthTimestamp token:token];

	// build the signature
	NSString* oauthSignature = [Utilities getHmacSha1:sigBaseString secretKey:[NSString stringWithFormat:@"%@&%@", oauthConsumerSecretKey, secret]];
	
	// set up the body
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString* stringBoundary = [(NSString*)CFUUIDCreateString(NULL, uuid) autorelease];
	CFRelease(uuid);
	NSMutableData* bodyData = [NSMutableData data];
	[bodyData appendData: [[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

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
	NSString* authHeader = [self genAuthHeader:tempNam consumerKey:oauthConsumerKey signature:oauthSignature nonce:oauthNonce timestamp:oauthTimestamp token:token];
	
	// add the custom headers
	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
	[request addValue:authHeader forHTTPHeaderField:@"Authorization"];
	[request addValue:[NSString stringWithFormat:@"%lu", [bodyData length]]	forHTTPHeaderField:@"Content-Length"];
	
	// set the data
	[request setHTTPBody:bodyData];
	
	// do the upload
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
	[AppDelegate statusProcessing];
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString* textResponse = [NSString stringWithUTF8String:[data bytes]];
	if (error)
	{
		NSLog(@"Error while attempting to upload to Dropbox: %@", [error description]);
	}
	else if ([response statusCode] != 200)
	{
		if ([response statusCode] == 401)
		{
			// this means the token has expired (unlikely, since it is given out for 10 years) or revoked, which means
			// we need to re-authenticate, so we should wipe out the stored token since it's no longer valid
			[self unlinkAccount];
		}
		else
		{
			NSString* result = [[textResponse JSONValue] valueForKey:@"error"];
			NSLog(@"Received the following error message when trying to upload to Dropbox: %@", result);
		}
	}
	else
	{
		NSString* result = [[textResponse JSONValue] valueForKey:@"result"];
		if ([result isEqualToString:@"winner!"])
		{
			NSInteger uid = [defaults integerForKey:@"DropboxUID"];
			NSString* publicLink = [NSString stringWithFormat:@"http://dl.dropbox.com/u/%lu/Captured/%@", uid, tempNam];
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"CloudProvider", @"Type",
								  publicLink , @"ImageURL",
								  [NSString stringWithFormat:@"https://api.dropbox.com/0/fileops/delete?root=dropbox&path=%@", [Utilities URLEncode:[NSString stringWithFormat:@"/Public/Captured/%s", tempNam]]], @"DeleteImageURL",
								  sourceFile, @"FilePath",
								  nil];
			[AppDelegate uploadSuccess:dict];
		}
		else
		{
			[AppDelegate uploadFailure];
		}
	}
}

- (NSString*)genSigBaseString:(NSString*)url method:(NSString*)method fileName:(NSString*)fileName consumerKey:(NSString*)consumerKey nonce:(NSString*)nonce timestamp:(unsigned long)timestamp token:(NSString*)token {
	NSString* sigBaseString;
	
	// if there is a file in the url, we format it slightly differently
	if (fileName == nil && token == nil)
		sigBaseString = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%lu&oauth_version=1.0", consumerKey, nonce, timestamp];
	else if (fileName == nil)
		sigBaseString = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%lu&oauth_token=%@&oauth_version=1.0", consumerKey, nonce, timestamp, token];
	else if (token == nil)
		sigBaseString = [NSString stringWithFormat:@"file=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%lu&oauth_version=1.0", fileName, consumerKey, nonce, timestamp];
	else
		sigBaseString = [NSString stringWithFormat:@"file=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%lu&oauth_token=%@&oauth_version=1.0", fileName, consumerKey, nonce, timestamp, token];
	
	// create an encoding object
	
	// url-encode the parts that need to be url-encoded
	NSString* escapedUrl = [Utilities URLEncode:url];
    NSString* escapedSig = [Utilities URLEncode:sigBaseString];
	
	// format them all into the signature base string
	NSString* finalString = [NSString stringWithFormat:@"%@&%@&%@", method, escapedUrl, escapedSig];
	
	return finalString;
}

// this method builds up the Authorization header that we will need to send in the request
- (NSString*)genAuthHeader:(NSString*)fileName consumerKey:(NSString*)consumerKey signature:(NSString*)signature nonce:(NSString*)nonce timestamp:(unsigned long)timestamp token:(NSString*)token {
	if (fileName == nil && token == nil)
		return [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_signature=\"%@\", oauth_timestamp=\"%lu\", oauth_nonce=\"%@\", oauth_version=\"1.0\"", consumerKey, signature, timestamp, nonce];
	else if (fileName == nil)
		return [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_signature=\"%@\", oauth_timestamp=\"%lu\", oauth_nonce=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\"", consumerKey, signature, timestamp, nonce, token];
	else if (token == nil)
		return [NSString stringWithFormat:@"OAuth file=\"%@\", oauth_consumer_key=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_signature=\"%@\", oauth_timestamp=\"%lu\", oauth_nonce=\"%@\", oauth_version=\"1.0\"", fileName, consumerKey, signature, timestamp, nonce];
	else
		return [NSString stringWithFormat:@"OAuth file=\"%@\", oauth_consumer_key=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_signature=\"%@\", oauth_timestamp=\"%lu\", oauth_nonce=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\"", fileName, consumerKey, signature, timestamp, nonce, token];
}

-(NSString*)genRandString {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID

	//get the string representation of the UUID
	NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);

	CFRelease(uuidObj);
	
	return [uuidString autorelease];
}

- (NSString*)linkAccount:(NSString*)email password:(NSString*)password {
	NSString* linkResponse = @"Success";
	
	// create the url and request
	NSURL* url = [NSURL URLWithString:@"https://api.dropbox.com/0/token"];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	
	// timestamp and nonce generation
	time_t timestamp = time(NULL);
	NSString* nonce = [self genRandString];
	
	// format the signature base string
	NSString* sigBaseString = [self genSigBaseString:[url absoluteString] method:@"POST" fileName:nil consumerKey:oauthConsumerKey nonce:nonce timestamp:timestamp token:nil];
	
	// build the signature
	NSString* oauthSignature = [Utilities getHmacSha1:sigBaseString secretKey:oauthConsumerSecretKey];
	
	// build the authentication header
	NSString* authHeader = [self genAuthHeader:nil consumerKey:oauthConsumerKey signature:oauthSignature nonce:nonce timestamp:timestamp token:nil];
	
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
		NSString* textResponse = [NSString stringWithUTF8String:[data bytes]];
		NSDictionary* dict = [textResponse JSONValue];
		linkResponse = [NSString stringWithFormat:@"%@", [dict valueForKey:@"error"]];
	}
	else
	{
		// get the new token and secret
		NSString* textResponse = [NSString stringWithUTF8String:[data bytes]];
		NSDictionary* dict = [textResponse JSONValue];
		NSString* newToken = [dict valueForKey:@"token"];
		NSString* newSecret = [dict valueForKey:@"secret"];
		
		// store there in user defaults, may want to move them elsewhere at some point
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:newToken forKey:@"DropboxToken"];
		[defaults setValue:newSecret forKey:@"DropboxSecret"];
		
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
	NSString* nonce = [self genRandString];
	
	// get the user settings
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* token = [defaults stringForKey:@"DropboxToken"];
	NSString* secret = [defaults stringForKey:@"DropboxSecret"];
	
	// generate oauth signature
	NSString* sigBaseString = [self genSigBaseString:[url absoluteString] method:@"GET" fileName:nil consumerKey:oauthConsumerKey nonce:nonce timestamp:timestamp token:token];
	NSString* oauthSignature = [Utilities getHmacSha1:sigBaseString secretKey:[NSString stringWithFormat:@"%@&%@", oauthConsumerSecretKey, secret]];
	
	// build the custom headers
	NSString* authHeader = [self genAuthHeader:nil consumerKey:oauthConsumerKey signature:oauthSignature nonce:nonce timestamp:timestamp token:token];
	
	// add the custom headers
	[request addValue:authHeader forHTTPHeaderField:@"Authorization"];

	// make the request
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString* textResponse = [NSString stringWithUTF8String:[data bytes]];
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
}

- (BOOL)isAccountLinked
{
	// account is linked if we have a token/secret pair
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* token = [defaults stringForKey:@"DropboxToken"];
	NSString* secret = [defaults stringForKey:@"DropboxSecret"];
	
	return (token && [token length] > 0 && secret && [secret length] > 0);
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
