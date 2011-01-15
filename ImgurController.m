#import "ASIFormDataRequest.h"
#import "ImgurController.h"
#import "Utilities.h"
#import "CapturedAppDelegate.h"
#import "XMLReader.h"

#define API_KEY @"343d3562a7a1533019b9994c68deb896" // Captured Mac API Key
//#define API_KEY @"f4fa5e1e9974405c62117a8a84fbde46" // Captured.rb API Key

@implementation ImgurController

@synthesize imageSelection, imageSelectionData, xmlResponseData;

#pragma mark  Imgur API Access Method
- (void) uploadImage: (NSData *) data; {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusPreparing"
                                                        object:self];
	imageSelectionData = data;
	
    NSURL *imgurURL = [NSURL URLWithString:@"http://imgur.com/api/upload"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:imgurURL];
    [request setDelegate:self];
    [request setPostValue:[NSString stringWithString:API_KEY] forKey:@"key"];
    [request setData:imageSelectionData  forKey:@"image"]; 
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusUploadStarting"
                                                        object:self];
    [request startAsynchronous];
	
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusUploading"
                                                        object:self];
	
}

#pragma mark ASIFormData Delegate Methods
- (void) requestFinished: (ASIFormDataRequest *) request {
	NSData * myData = [request rawResponseData];
	
	if (request.responseStatusCode != 200) {
		NSLog(@"Imagur responseStatusCode: %d", request.responseStatusCode);
		[self requestFailed:nil];
	}
	else{
		NSLog(@"Imagur Response: %.*s", [myData length], [myData bytes]);
		
		NSString * body = [NSString stringWithFormat:@"%.*s",[myData length], [myData bytes]];
		
		NSString *url = [self parseResponseForURL:body];
		
		[CapturedAppDelegate uploadSuccess:url];
	}
	
}

- (void) requestFailed: (ASIFormDataRequest *) request {
	[CapturedAppDelegate uploadFailure];
}

#pragma mark NSXMLParser Delegate Methods
- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict {
    ;   
}

- (void) parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string {
    ;   
}

- (void) processFile:(NSString*)filename {

	[CapturedAppDelegate statusProcessing];
	NSData* data = [NSData dataWithContentsOfFile: filename];
	[self uploadImage:data];
}

- (NSString *) parseResponseForURL: (NSString*)str {
	//str = @"<rfsp stat=\"ok\"><image_hash>h179y</image_hash><delete_hash>x5GiPOfeD2Vi3t5</delete_hash><original_image>http://i.imgur.com/h179y.png</original_image><large_thumbnail>http://i.imgur.com/h179yl.jpg</large_thumbnail><small_thumbnail>http://i.imgur.com/h179ys.jpg</small_thumbnail><imgur_page>http://imgur.com/h179y</imgur_page><delete_page>http://imgur.com/delete/x5GiPOfeD2Vi3t5</delete_page></rsp>";
	
	NSError *error = nil;
	NSDictionary* dictionary = [XMLReader dictionaryForXMLString:str error:&error];
	
	// This looks something like this:
	/*
	 {
		rsp =     {
			"delete_hash" =         {
				text = x5GiPOfeD2Vi3t5;
			};
			"delete_page" =         {
				text = "http://imgur.com/delete/x5GiPOfeD2Vi3t5";
			};
			"image_hash" =         {
				text = h179y;
			};
			"imgur_page" =         {
				text = "http://imgur.com/h179y";
			};
			"large_thumbnail" =         {
				text = "http://i.imgur.com/h179yl.jpg";
			};
			"original_image" =         {
				text = "http://i.imgur.com/h179y.png";
			};
			"small_thumbnail" =         {
				text = "http://i.imgur.com/h179ys.jpg";
			};
			stat = ok;
		};
	}
	 */
	
	 
	//return [[[dictionary objectForKey:@"rsp"] valueForKey:@"imgur_page"]  valueForKey:@"text"];
	return [[[dictionary objectForKey:@"rsp"] valueForKey:@"original_image"]  valueForKey:@"text"];
}

@end
