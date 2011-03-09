#import "ASIFormDataRequest.h"
#import "Imgur.h"
#import "Utilities.h"
#import "CapturedAppDelegate.h"
#import "XMLReader.h"
#import "ImgurURL.h"


#define API_KEY @"343d3562a7a1533019b9994c68deb896" // Captured Mac API Key

@implementation Imgur

@synthesize imageSelection, imageSelectionData, xmlResponseData;

#pragma mark  Imgur API Access Method
- (void) uploadImage: (NSData *) data; {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusPreparing"
                                                        object:self];
	imageSelectionData = data;
	
    NSURL *imgurURL = [NSURL URLWithString:@"http://api.imgur.com/2/upload.xml"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:imgurURL];
    [request setDelegate:self];
    [request setPostValue:[NSString stringWithString:API_KEY] forKey:@"key"];
    [request setPostValue:[NSString stringWithString:@"Uploaded by Captured for Mac"] forKey:@"caption"];
    [request setPostValue:[NSString stringWithString:@"Screen Capture"] forKey:@"title"];
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
		NSLog(@"Upload Failed");
		NSLog(@"Imagur responseStatusCode: %d", request.responseStatusCode);
		NSLog(@"Imagur Response: %.*s", [myData length], [myData bytes]);
		[self requestFailed:nil];
	}
	else{
		NSLog(@"Imagur Response: %.*s", [myData length], [myData bytes]);
		NSString * body = [NSString stringWithFormat:@"%.*s",[myData length], [myData bytes]];
		ImgurURL *url = [self parseResponseForURL:body];
		[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadSuccess:url];
	}
}

- (void) requestFailed: (ASIFormDataRequest *) request {
	NSData * myData = [request rawResponseData];
	NSLog(@"Upload Failed");
	[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] uploadFailure];
	NSLog(@"Imagur responseStatusCode: %d", request.responseStatusCode);
	NSLog(@"Imagur Response: %.*s", [myData length], [myData bytes]);
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

	[(CapturedAppDelegate *)[[NSApplication sharedApplication] delegate] statusProcessing];
	NSData* data = [NSData dataWithContentsOfFile: filename];
	[self uploadImage:data];
}

- (ImgurURL *) parseResponseForURL: (NSString*)str {
	/*
	 Imgur API V2:
		<?xml version="1.0"?>
		<upload>
		  <image>
			<name/>
			<title/>
			<caption/>
			<hash>Vyutl</hash>
			<deletehash>r9XaxqTVloHazYz</deletehash>
			<datetime>2011-01-19 19:08:12</datetime>
			<type>image/png</type>
			<animated>false</animated>
			<width>170</width>
			<height>143</height>
			<size>10209</size>
			<views>0</views>
			<bandwidth>0</bandwidth>
		  </image>
		  <links>
			<original>http://imgur.com/Vyutl.png</original>
			<imgur_page>http://imgur.com/Vyutl</imgur_page>
			<delete_page>http://imgur.com/delete/8COe0BicrWO80nk</delete_page>
			<small_square>http://imgur.com/Vyutls.jpg</small_square>
			<large_thumbnail>http://imgur.com/Vyutll.jpg</large_thumbnail>
		  </links>
		</upload>
	 */

	NSError *error = nil;
	NSDictionary* dictionary = [XMLReader dictionaryForXMLString:str error:&error];
	
	// This looks something like this:
	/*
		{
		  upload = {
			image = {
			  animated = { text = false; };
			  bandwidth = { text = 0; };
			  caption = { };
			  datetime = { text = "2011-01-19 19:13:07"; };
			  deletehash = { text = ; };
			  hash = { text = 4DOIa; };
			  height = { text = 48; };
			  name = { };
			  size = { text = 17042; };
			  title = { };
			  type = { text = "image/png"; };
			  views = { text = 0; };
			  width = { text = 423; };
			};
			links = {
			  "delete_page" = { text = "http://imgur.com/delete/IwUTdDHnzRtht4u"; };
			  "imgur_page" = { text = "http://imgur.com/4DOIa"; };
			  "large_thumbnail" = { text = "http://imgur.com/4DOIal.jpg"; };
			  original = { text = "http://imgur.com/4DOIa.png"; };
			  "small_square" = { text = "http://imgur.com/4DOIas.jpg"; };
			};
		  };
		}

	 */
	

	// This should probably be moved somewhere to a common instance of NSUserDefaults, but right now
	// I only need the one setting so this seems stupid simple
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys: @"imgur_page",  @"ImgurKey",	nil]];
	NSString * imgurKey = [defaults stringForKey:@"ImgurKey"];

	NSDictionary *upload = [dictionary objectForKey:@"upload"];
	//NSDictionary *image = [upload valueForKey:@"image"];
	NSDictionary *links = [upload valueForKey:@"links"];
    
    ImgurURL *imgFile = [[ImgurURL alloc] init];
    imgFile.imageURL = [[links valueForKey:imgurKey]  valueForKey:@"text"];
    imgFile.imageDeleteURL = [[links valueForKey:@"delete_page"] valueForKey:@"text"];
	
	return imgFile;

}

@end
