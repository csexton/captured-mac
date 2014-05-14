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
        NSLog(@"Unable to shorten URL with Bit.ly, falling back to the full URL. Missing bit.ly Login or API Key.");
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
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (error)
	{
		// we failed to shorten, better to return the original URL than nothing at all
		NSLog(@"Error while calling URL shortener: %@", [error description]);
		return longUrl;
	}
    
	// parse out the json response and return the short url
	NSString* json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSNumber* statusCode = (NSNumber*) [[json JSONValue] valueForKey:@"status_code"];
    if ([statusCode intValue] != 200) {
        NSLog(@"Unable to shorten URL with Bit.ly, falling back to the full URL.");
        NSLog(@"Bit.ly Response: %.*s", (int) [data length], [data bytes]);
        return longUrl;
    }
    
    NSDictionary* dict = [[json JSONValue] valueForKey:@"data"];
	return [dict valueForKey:@"url"];
}

@end
