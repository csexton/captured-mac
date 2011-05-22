//
//  main.m
//  Captured
//
//  Created by Christopher Sexton on 1/13/11.
//  Copyright Codeography 2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "validatereceipt.h"

#include <curl/curl.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
#ifdef DONT_VALIDATE_RECEIPT
#warning *** DOES NOT VALIDATE RECEIPT! DO NOT RELEASE TO STORE! ***
#else
	// put the example receipt on the desktop (or change that path)
	//NSString * pathToReceipt = @"~/src/Captured/receipt";
	NSString * pathToReceipt = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"];
	if (!validateReceiptAtPath(pathToReceipt)) { 
		exit(173); 
	}
#endif	

	// we call this here because it is not thread safe...if we don't do it here, on the main thread, then it will
	// be called implicitly when we call curl_easy_init(), which is on a UI thread, so that could lead to bad things
	curl_global_init(CURL_GLOBAL_ALL);
	
	int ret = NSApplicationMain(argc,  (const char **) argv);
    [pool drain];
	
	curl_global_cleanup();
	
    return ret;
}

