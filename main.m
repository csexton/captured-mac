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

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// put the example receipt on the desktop (or change that path)
	//NSString * pathToReceipt = @"~/Desktop/receipt";
	NSString * pathToReceipt = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"];

	if (!validateReceiptAtPath(pathToReceipt)) { 
		exit(173); 
	}
	
    NSLog(@"Hello, correctly validated World!");
	int ret = NSApplicationMain(argc,  (const char **) argv);
    [pool drain];
    return ret;
}

