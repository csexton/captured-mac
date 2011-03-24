//
//  DropboxUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "Utilities.h"
#import "JSON/JSON.h"
#import "UrlShortener.h"
#import "DropboxUploader.h"

// these are the Dropbox API keys, keep them safe
static NSString* oauthConsumerKey = @"bpsv3nx35j5hua7";
static NSString* oauthConsumerSecretKey = @"qa9tvwoivvspknm";

// user tokens, these will need to be requested once and then stored
static NSString* token = @"nx7s0yvpe6654x6";
static NSString* secret = @"zspeub00bk58qlr";

// characters suitable for generating a unique nonce
static char* nonceChars = "abcdefghijklmnopqrstuvwxyz0123456789";

size_t write_func(void *ptr, size_t size, size_t nmemb, void *userdata);

@implementation DropboxUploader

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
	// generate a unique filename
	char tempNam[16];
	strcpy(tempNam, "XXXXX.png");
	mkstemps(tempNam, 4);
	
	// set up the url
	NSURL* url = [NSURL URLWithString:@"https://api-content.dropbox.com/0/files/dropbox/Public"];
	
	// now the request
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	NSString* httpVerb = @"POST";
	[request setHTTPMethod:httpVerb];
	
	// generate a unique nonce for this request
	time_t oauthTimestamp = time(NULL);
	NSString* oauthNonce = [self genRandStringLength:16 seed:oauthTimestamp];
	
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
	[bodyData appendData: [[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n", tempNam] dataUsingEncoding:NSASCIIStringEncoding]];
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
	NSURLResponse* response = nil;
	NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (!error)
	{
		NSString* textResponse = [NSString stringWithUTF8String:[data bytes]];
		NSString* result = [[textResponse JSONValue] valueForKey:@"result"];
		if ([result isEqualToString:@"winner!"])
		{
			NSString* publicLink = [NSString stringWithFormat:@"http://dl.dropbox.com/u/%lu/%s", 3893484, tempNam];
			NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
			BOOL shortenUrl = [defaults boolForKey:@"UseURLShortener"];
			if (shortenUrl)
				publicLink = [UrlShortener shorten:publicLink];
			NSLog(@"File successfully uploaded to Dropbox and accessible at %@", publicLink);
		}
	}
		
	return 0;
}

- (NSInteger)testConnection
{
	return 0;
}

- (NSString*)genSigBaseString:(NSString*)url method:(NSString*)method fileName:(const char*)fileName consumerKey:(NSString*)consumerKey nonce:(NSString*)nonce timestamp:(unsigned long)timestamp token:(NSString*)token {
	NSString* sigBaseString;
	
	// if there is a file in the url, we format it slightly differently
	if (fileName == NULL)
		sigBaseString = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%lu&oauth_token=%@&oauth_version=1.0", consumerKey, nonce, timestamp, token];
	else
		sigBaseString = [NSString stringWithFormat:@"file=%s&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%lu&oauth_token=%@&oauth_version=1.0", fileName, consumerKey, nonce, timestamp, token];
	
	// create an encoding object
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
	CFStringRef escapeChars = (CFStringRef) @":?=,!$&'()*+;[]@#~/";
	
	// url-encode the parts that need to be url-encoded
	NSString* escapedUrl = (NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) url, NULL, escapeChars, encoding);
    NSString* escapedSig = (NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) sigBaseString, NULL, escapeChars, encoding);
	
	// format them all into the signature base string
	NSString* finalString = [NSString stringWithFormat:@"%@&%@&%@", method, escapedUrl, escapedSig];
	
	return finalString;
}

// this method builds up the Authorization header that we will need to send in the request
- (NSString*)genAuthHeader:(const char*)fileName consumerKey:(NSString*)consumerKey signature:(NSString*)signature nonce:(NSString*)nonce timestamp:(unsigned long)timestamp token:(NSString*)token {
	if (fileName == NULL)
		return [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_signature=\"%@\", oauth_timestamp=\"%lu\", oauth_nonce=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\"", consumerKey, signature, timestamp, nonce, token];
	else
		return [NSString stringWithFormat:@"OAuth file=\"%s\", oauth_consumer_key=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_signature=\"%@\", oauth_timestamp=\"%lu\", oauth_nonce=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\"", fileName, consumerKey, signature, timestamp, nonce, token];
}

-(NSString*)genRandStringLength:(int)len seed:(unsigned long)seed {
	// create a mutable string to hold the random string
	NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
	
	// give it a random seed based on the time
	srand(seed);
	
	// build up the string from random characters
	for (int i=0; i<len; i++) {
		[randomString appendFormat: @"%c", nonceChars[rand() % strlen(nonceChars)]];
	}
		 
	return randomString;
}

- (NSInteger)getToken:(NSString*)username password:(NSString*)password {
	return 0;
}

- (NSUInteger)getAccountId {
//	// timestamp and nonce generation
//	time_t timestamp = time(NULL);
//	NSString* nonce = [self genRandStringLength:16 seed:timestamp];
//	
//	// URL for this request
//	NSString* url = @"https://api.dropbox.com/0/account/info";
//	rc = curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
//	
//	// generate oauth signature
//	NSString* sigBaseString = [self genSigBaseString:url method:@"GET" fileName:NULL consumerKey:oauthConsumerKey nonce:nonce timestamp:timestamp token:token];
//	NSString* oauthSignature = [Utilities getHmacSha1:sigBaseString secretKey:[NSString stringWithFormat:@"%@&%@", oauthConsumerSecretKey, secret]];
//	
//	// build the custom headers
//	NSString* authHeader = [self genAuthHeader:NULL consumerKey:oauthConsumerKey signature:oauthSignature nonce:nonce timestamp:timestamp token:token];
//	
//	// add the custom headers
//	struct curl_slist *slist = NULL;
//	slist = curl_slist_append(slist, [authHeader UTF8String]);
//	curl_easy_setopt(handle, CURLOPT_HTTPHEADER, slist);
//	
//	// collect the response
//	char* data = malloc(4096); // should be plenty of room for the response
//	data[0] = 0;
//	rc = curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, write_func);
//	rc = curl_easy_setopt(handle, CURLOPT_WRITEDATA, data);
//	
//	// make the request
//	rc = curl_easy_perform(handle);
//	curl_slist_free_all(slist);
//	NSString* response = [NSString stringWithCString:data encoding:NSUTF8StringEncoding];
//	free(data);
//	if (rc == CURLE_OK)
//	{
//		long status_code;
//		rc = curl_easy_getinfo(handle, CURLINFO_RESPONSE_CODE, &status_code);
//		if (rc == CURLE_OK && status_code == 200)
//		{
//			// parse out the account id from the response
//			uid = [[[response JSONValue] valueForKey:@"uid"] intValue];
//		}
//	}
		
	return 0;
}

@end
