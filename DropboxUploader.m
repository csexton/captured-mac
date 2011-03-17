//
//  DropboxUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/16/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>

#import "CloudUploader.h"
#import "DropboxUploader.h"

// these are the Dropbox API keys, keep them safe
static char* oauthConsumerKey = "bpsv3nx35j5hua7";
static char* oauthConsumerSecretKey = "qa9tvwoivvspknm";

// user tokens, these will need to be requested once and then stored
NSString* token = @"nx7s0yvpe6654x6";
NSString* secret = @"zspeub00bk58qlr";

// characters suitable for generating a unique nonce
static char* nonceChars = "abcdefghijklmnopqrstuvwxyz0123456789";

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
		
	// generate a unique filename
	char tempNam[16];
	strcpy(tempNam, "XXXXX.png");
	mkstemps(tempNam, 4);
	
	// set the url
	NSString* url = @"https://api-content.dropbox.com/0/files/dropbox/Public";
	rc = curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
	
	// generate a unique nonce for this request
	time_t oauthTimestamp = time(NULL);
	NSString* oauthNonce = [self genRandStringLength:16 seed:oauthTimestamp];
	
	// format the signature base string
	NSString* sigBaseString = [self genSigBaseString:url method:@"POST" fileName:tempNam consumerKey:oauthConsumerKey nonce:oauthNonce timestamp:oauthTimestamp token:token];

	// build the signature
	NSString* oauthSignature = [self genOAuthSig:sigBaseString consumerSecret:oauthConsumerSecretKey userSecret:secret];
	
	// set up the body
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString* stringBoundary = [(NSString*)CFUUIDCreateString(NULL, uuid) autorelease];
	CFRelease(uuid);
	NSMutableData* bodyData = [NSMutableData data];
	[bodyData appendData: [[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

	// Add data to upload
	[bodyData appendData: [[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n", tempNam] dataUsingEncoding:NSUTF8StringEncoding]];
	[bodyData appendData: [[NSString stringWithString:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

	// create a temp file we'll use for the mime-encoding
	NSString* tempFilename = [NSString stringWithFormat: @"%.0f.txt", [NSDate timeIntervalSinceReferenceDate] * 1000.0];
	NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempFilename];
	if (![[NSFileManager defaultManager] createFileAtPath:tempFilePath contents:bodyData attributes:nil]) {
		NSLog(@"failed to create file");
		return -1;
	}

	// get a handle so we can append data to the mime file
	NSFileHandle* bodyFile = [NSFileHandle fileHandleForWritingAtPath:tempFilePath];
	[bodyFile seekToEndOfFile];

	// write the raw file data to the mime file
	if ([[NSFileManager defaultManager] fileExistsAtPath:sourceFile]) {
		NSFileHandle* readFile = [NSFileHandle fileHandleForReadingAtPath:sourceFile];
		NSData* readData;
		while ((readData = [readFile readDataOfLength:1024 * 512]) != nil && [readData length] > 0) {
			@try {
				[bodyFile writeData:readData];
			} @catch (NSException* e) {
				NSLog(@"failed to write data");
				[readFile closeFile];
				[bodyFile closeFile];
				[[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
				return -1;
			}
		}
		[readFile closeFile];
	} else {
		NSLog(@"unable to open sourceFile");
	}
	
	// write the end boundary to the mime file
    @try {
		[bodyFile writeData: [[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	} @catch (NSException* e) {
		NSLog(@"failed to write end of data");
		[bodyFile closeFile];
		[[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
		return -1;
	}
	[bodyFile closeFile];
	
	// dropbox wants a POST
	rc = curl_easy_setopt(handle, CURLOPT_POST, 1);
	
	// build the custom headers
	NSString* authHeader = [self genAuthHeader:tempNam consumerKey:oauthConsumerKey signature:oauthSignature nonce:oauthNonce timestamp:oauthTimestamp token:token];
	NSString* contentTypeHeader = [NSString stringWithFormat:@"Content-Type: multipart/form-data; boundary=%@", stringBoundary];
	
	// add the custom headers
	struct curl_slist *slist = NULL;
	slist = curl_slist_append(slist, [contentTypeHeader UTF8String]);
	slist = curl_slist_append(slist, [authHeader UTF8String]);
	curl_easy_setopt(handle, CURLOPT_HTTPHEADER, slist);
	
	// get the file pointer for passing
	FILE* fp = fopen([tempFilePath UTF8String], "rb");
	rc = curl_easy_setopt(handle, CURLOPT_READDATA, fp);
	
	// set the size of the data
	NSDictionary* dict = [[NSFileManager defaultManager] attributesOfItemAtPath:tempFilePath error:nil];
	unsigned long long size = [dict fileSize];
	rc = curl_easy_setopt(handle, CURLOPT_POSTFIELDSIZE, size);

	// do the upload
	rc = curl_easy_perform(handle);
	curl_slist_free_all(slist);
	if (rc == CURLE_OK)
	{
		long response_code;
		rc = curl_easy_getinfo(handle, CURLINFO_RESPONSE_CODE, &response_code);
		if (rc == CURLE_OK && response_code == 200)
		{
			// if we got back 200 from the server, format the link for sharing
			NSString* publicLink = [NSString stringWithFormat:@"http://dl.dropbox.com/u/%@/%s", [self getAccountId], tempNam];
			NSLog(@"File successfully uploaded to Dropbox and accessible at %@", publicLink);
		}
	}
	
	// clean up - remove the temporary mime-encoded file and close the file pointer for the source file
	[[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
	fclose(fp);
	
	return rc;
}

- (NSInteger)testConnection
{
	CURLcode rc = CURLE_OK;
	
	rc = curl_easy_perform(handle);
	
	return rc;
}

- (NSString*)genSigBaseString:(NSString*)url method:(NSString*)method fileName:(const char*)fileName consumerKey:(const char*)consumerKey nonce:(NSString*)nonce timestamp:(unsigned long)timestamp token:(NSString*)token {
	NSString* sigBaseString;
	
	// if there is a file in the url, we format it slightly differently
	if (fileName == NULL)
		sigBaseString = [NSString stringWithFormat:@"oauth_consumer_key=%s&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%lu&oauth_token=%@&oauth_version=1.0", consumerKey, nonce, timestamp, token];
	else
		sigBaseString = [NSString stringWithFormat:@"file=%s&oauth_consumer_key=%s&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%lu&oauth_token=%@&oauth_version=1.0", fileName, consumerKey, nonce, timestamp, token];
	
	// create an encoding object
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
	
	// url-encode the parts that need to be url-encoded
	NSString* escapedUrl = [(NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) url, NULL, (CFStringRef) @":?=,!$&'()*+;[]@#~/", encoding) autorelease];
    NSString* escapedPath = [(NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) sigBaseString, NULL, (CFStringRef) @":?=,!$&'()*+;[]@#~/", encoding) autorelease];
	
	// format them all into the signature base string
	sigBaseString = [NSString stringWithFormat:@"%@&%@&%@", method, escapedUrl, escapedPath];
	
	return sigBaseString;
}

- (NSString*)genOAuthSig:(NSString*)sigBaseString consumerSecret:(const char*)consumerSecret userSecret:(NSString*)userSecret {
	// convert the string to data so we can generate the HMAC
 	NSData* dataToSign = [sigBaseString dataUsingEncoding:NSASCIIStringEncoding];
	CCHmacContext context;
	unsigned char digestRaw[CC_SHA1_DIGEST_LENGTH];
	
	// the key is made by joining the consumer secret key and the user secret key
	NSString* keyToSign = [NSString stringWithFormat:@"%s&%@", consumerSecret, userSecret];
	CCHmacInit(&context, kCCHmacAlgSHA1, [keyToSign cStringUsingEncoding:NSASCIIStringEncoding], [keyToSign length]);
	CCHmacUpdate(&context, [dataToSign bytes], [dataToSign length]);
	CCHmacFinal(&context, digestRaw);
	
	// get the digest into a NSData object
	NSData *digestData = [NSData dataWithBytes:digestRaw length:CC_SHA1_DIGEST_LENGTH];
	
	// return the base 64 encoding of the digest
	return [digestData base64EncodedString];;
}

// this method builds up the Authorization header that we will need to send in the request
- (NSString*)genAuthHeader:(const char*)fileName consumerKey:(const char*)consumerKey signature:(NSString*)signature nonce:(NSString*)nonce timestamp:(unsigned long)timestamp token:(NSString*)token {
	if (fileName == NULL)
		return [NSString stringWithFormat:@"Authorization: OAuth oauth_consumer_key=\"%s\", oauth_signature_method=\"HMAC-SHA1\", oauth_signature=\"%@\", oauth_timestamp=\"%lu\", oauth_nonce=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\"", consumerKey, signature, timestamp, nonce, token];
	else
		return [NSString stringWithFormat:@"Authorization: OAuth file=\"%s\", oauth_consumer_key=\"%s\", oauth_signature_method=\"HMAC-SHA1\", oauth_signature=\"%@\", oauth_timestamp=\"%lu\", oauth_nonce=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\"", fileName, consumerKey, signature, timestamp, nonce, token];
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
	CURLcode rc = CURLE_OK;
	
	// reset the curl handle for this request
	curl_easy_reset(handle);
	
	// timestamp and nonce generation
	time_t timestamp = time(NULL);
	NSString* nonce = [self genRandStringLength:16 seed:timestamp];
	
	// URL for this request
	NSString* url = @"https://api.dropbox.com/0/account/info";
	rc = curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
	
	// generate oauth signature
	NSString* sigBaseString = [self genSigBaseString:url method:@"GET" fileName:NULL consumerKey:oauthConsumerKey nonce:nonce timestamp:timestamp token:token];
	NSString* oauthSignature = [self genOAuthSig:sigBaseString consumerSecret:oauthConsumerSecretKey userSecret:secret];
	
	// build the custom headers
	NSString* authHeader = [self genAuthHeader:NULL consumerKey:oauthConsumerKey signature:oauthSignature nonce:nonce timestamp:timestamp token:token];
	
	// add the custom headers
	struct curl_slist *slist = NULL;
	slist = curl_slist_append(slist, [authHeader UTF8String]);
	curl_easy_setopt(handle, CURLOPT_HTTPHEADER, slist);
	
	// make the request
	rc = curl_easy_perform(handle);
	curl_slist_free_all(slist);
	
	return 0;
}

@end
