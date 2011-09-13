#import "ASIFormDataRequest.h"
#import "ImgurUploader.h"
#import "Utilities.h"
#import "JSON/JSON.h"
#import "XMLReader.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OAToken.h"

NSString* imgurConsumerKey = @"ef8c51ce1140df5ff9cfe16f17b3d36704e6c0b48";
NSString* imgurConsumerSecret = @"dfc121fc4ae74e8298d03eefad638632";
#define API_KEY @"343d3562a7a1533019b9994c68deb896" // Captured Mac API Key

@implementation ImgurUploader

@synthesize imageSelection, imageSelectionData, xmlResponseData, filePathName;

#pragma mark  Imgur API Access Method
- (void) performUpload: (NSData *) data; {
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
		NSLog(@"Imgur responseStatusCode: %d", request.responseStatusCode);
		NSLog(@"Imgur Response: %.*s", [myData length], [myData bytes]);
		[self requestFailed:nil];
	}
	else{
		NSLog(@"Imgur Response: %.*s", [myData length], [myData bytes]);
		NSString * body = [NSString stringWithFormat:@"%.*s",[myData length], [myData bytes]];
		NSDictionary *dict = [self parseResponseForURL:body];
        [self uploadSuccess:dict];
	}
}

- (void) requestFailed: (ASIFormDataRequest *) request {
	NSData * myData = [request rawResponseData];
	NSLog(@"Upload Failed");
	NSLog(@"Imgur responseStatusCode: %d", request.responseStatusCode);
	NSLog(@"Imgur Response: %.*s", [myData length], [myData bytes]);
    [self uploadFailed:nil];
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

- (void) uploadFile:(NSString*)filename {

    [self uploadStarted];
    self.filePathName = filename;
	NSData* data = [NSData dataWithContentsOfFile: filename];
	[self performUpload:data];
}

- (NSDictionary *) parseResponseForURL: (NSString*)str {
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
	NSString * linkType = [defaults stringForKey:@"ImgurLinkType"];
    NSString * imgurKey = @"imgur_page";
    if ([linkType isEqualToString:@"Copy URL to Direct Image"]) {
        imgurKey = @"original";
    }
         
	NSDictionary *upload = [dictionary objectForKey:@"upload"];
	//NSDictionary *image = [upload valueForKey:@"image"];
	NSDictionary *links = [upload valueForKey:@"links"];
        
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Imgur", @"Type",
                          [[links valueForKey:imgurKey]  valueForKey:@"text"], @"ImageURL", 
                          [[links valueForKey:@"delete_page"] valueForKey:@"text"], @"DeleteImageURL", 
                          [[links valueForKey:@"small_square"] valueForKey:@"text"], @"SmallSquareURL", 
                          [[links valueForKey:@"large_thumbnail"]  valueForKey:@"text"], @"LargeThumbnailURL", 
                          [[links valueForKey:@"original"]  valueForKey:@"text"], @"OriginalURL", 
                          self.filePathName, @"FilePath", 
                          nil];
	
	return dict;

}

- (BOOL)isAccountLinked
{
	// account is linked if we have a token/secret pair
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* displayName = [defaults stringForKey:@"ImgurToken"];
	
	return (displayName && [displayName length] > 0);
}

- (NSString*)linkAccount:(NSString*)email password:(NSString*)password {	
	// create the url and request
	NSURL* url = [NSURL URLWithString:@"https://api.imgur.com/oauth/request_token"];
	OAConsumer* consumer = [[OAConsumer alloc] initWithKey:imgurConsumerKey secret:imgurConsumerSecret];
	OAMutableURLRequest* request = [[OAMutableURLRequest alloc] initWithURL:url consumer:consumer token:nil realm:nil signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	
	// make the request
	OADataFetcher* fetcher = [[OADataFetcher alloc] init];
	[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) didFailSelector:@selector(requestTokenTicket:didFailWithError:)];

	return nil;
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		OAToken* requestToken = [[OAToken alloc] initWithHTTPResponseBody:response];
		NSURL* url = [NSURL URLWithString:@"https://api.imgur.com/oauth/authorize"];
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
}

- (void)unlinkAccount
{
	// remove the imgur token from our records
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"ImgurToken"];
	[defaults removeObjectForKey:@"ImgurSecret"];
}

@end
