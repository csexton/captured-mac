#import "ASIFormDataRequest.h"
#import "ImgurController.h"
#import "Utilities.h"
#import "CapturedAppDelegate.h"

#define API_KEY @"f4fa5e1e9974405c62117a8a84fbde46"

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
	NSLog(@"my Data: %.*s", [myData length], [myData bytes]);
}

- (void) requestFailed: (ASIFormDataRequest *) request {
    ;       
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
	[Utilities copyToPasteboard:filename]; // XXX
	[CapturedAppDelegate statusNormal];
}

@end
