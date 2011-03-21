//
//  UrlShortener.m
//  Captured
//
//  Created by Jorge Velázquez on 3/19/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "JSON/JSON.h"
#import "UrlShortener.h"
#import "Utilities.h"

@implementation UrlShortener

+ (NSString*)shorten:(NSString*)longUrl {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* login = [defaults stringForKey:@"BitlyLogin"];
	NSString* key = [defaults stringForKey:@"BitlyKey"];
    
    if (login == nil || key == nil) {

        [Utilities growlError:@"Y U NO HAVE BITLY CONFIGRS??"];
        return longUrl;
    }
    
    
	// need to url-encode the url we want shortened
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
	NSString* escapedLongUrl = [(NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) longUrl, NULL, (CFStringRef) @":?=,!$&'()*+;[]@#~/", encoding) autorelease];
	
	// format the request url using our api key for bitly
	NSString* path = [NSString stringWithFormat:@"http://api.bitly.com/v3/shorten?login=%@&apiKey=%@&longUrl=%@", login, key, escapedLongUrl];
	
	// build and execute the request
	NSURL* url = [NSURL URLWithString:path];
	NSURLRequest* request = [NSURLRequest requestWithURL:url];
	NSURLResponse* response;
	NSError* error;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (error)
	{
		// we failed to shorten, better to return the original URL than nothing at all
		NSLog(@"Error while calling URL shortener: %@", [error description]);
		return longUrl;
	}
	
	// parse out the json response and return the short url
	NSString* json = [NSString stringWithUTF8String:[data bytes]];
	NSDictionary* dict = [[json JSONValue] valueForKey:@"data"];
	return [dict valueForKey:@"url"];
}

@end
