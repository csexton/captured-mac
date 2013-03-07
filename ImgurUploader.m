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

- (void) dealloc {
	[requestToken release];
	[accessToken release];
	
	[super dealloc];
}

#pragma mark  Imgur API Access Method
- (void) performUpload: (NSData *) data
{
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusPreparing"
                                                            object:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to post notification %@", exception.reason);
    }

	imageSelectionData = data;
	
    NSURL *imgurURL = [NSURL URLWithString:@"http://api.imgur.com/2/upload.xml"];	
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:imgurURL];
    [request setDelegate:self];
    [request setPostValue:API_KEY forKey:@"key"];
    [request setPostValue:@"Uploaded by Captured for Mac" forKey:@"caption"];
    [request setPostValue:@"Screen Capture" forKey:@"title"];
    [request setData:imageSelectionData  forKey:@"image"];
    
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusUploadStarting"
                                                            object:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to post notification %@", exception.reason);
    }
    
    [request startAsynchronous];
    
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusUploading"
                                                            object:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to post notification %@", exception.reason);
    }

}

- (void) performUploadWithToken: (NSData *) data
{
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusPreparing"
                                                            object:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to post notification %@", exception.reason);
    }

    	
	NSURL* url = [NSURL URLWithString:@"http://api.imgur.com/2/upload.json"];
	OAConsumer* consumer = [[OAConsumer alloc] initWithKey:imgurConsumerKey secret:imgurConsumerSecret];
	OAMutableURLRequest* request = [[OAMutableURLRequest alloc] initWithURL:url consumer:consumer token:accessToken realm:nil signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	
	OARequestParameter* keyParam = [[OARequestParameter alloc] initWithName:@"key" value:API_KEY];
	OARequestParameter* imageParam = [[OARequestParameter alloc] initWithName:@"image" value:[data base64EncodedString]];
	
	NSArray* params = [NSArray arrayWithObjects:keyParam, imageParam, nil];
	[request setParameters:params];
	
	[self uploadStarted];

	// make the request
	OADataFetcher* fetcher = [[OADataFetcher alloc] init];
	[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(postImage:didFinishWithData:) didFailSelector:@selector(postImage:didFailWithError:)];
	
	// clean up
	[keyParam release];
	[imageParam release];
	[fetcher release];
	[request release];
	[consumer release];
    
    @try {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusUploading"
                                                            object:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to post notification %@", exception.reason);
    }
}
- (void)postImage:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		NSString * linkType = [defaults stringForKey:@"ImgurLinkType"];
		if ([linkType isEqualToString:@"Copy URL to Direct Image"])
			uploadUrl = [[response JSONValue] valueForKeyPath:@"upload.links.original"];
		else
			uploadUrl = [[response JSONValue] valueForKeyPath:@"upload.links.imgur_page"];
		deleteUrl = [[response JSONValue] valueForKeyPath:@"upload.links.delete_page"];
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"DropboxProvider", @"Type",
							  uploadUrl, @"ImageURL",
							  deleteUrl, @"DeleteImageURL",
							  self.filePathName, @"FilePath",
							  nil];
		[response release];
		[self uploadSuccess:dict];
	}
	else
	{
		[self uploadFailed:nil];
	}
}

- (void)postImage:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
}

#pragma mark ASIFormData Delegate Methods
- (void) requestFinished: (ASIFormDataRequest *) request {    
    NSLog(@"responseString %@", [request responseString]);
	
	if (request.responseStatusCode != 200) {
		NSLog(@"Upload Failed");
		NSLog(@"Imgur responseStatusCode: %d", request.responseStatusCode);
		NSLog(@"Imgur Response: %@", [request responseString]);
		[self requestFailed:nil];
	}
	else{
		NSLog(@"Imgur Response: %@", [request responseString]);
		NSString * body = [request responseString];
		NSDictionary *dict = [self parseResponseForURL:body];
        [self uploadSuccess:dict];
	}
}

- (void) requestFailed: (ASIFormDataRequest *) request {
	NSData * myData = [request rawResponseData];
	NSLog(@"Upload Failed");
	NSLog(@"Imgur responseStatusCode: %d", request.responseStatusCode);
	NSLog(@"Imgur Response: %@", [[[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding] autorelease]);
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
	if (!accessToken)
	{
		// user may have linked account since last time, so we check each time
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		NSString* key = [defaults stringForKey:@"ImgurKey"];
		NSString* secret = [defaults stringForKey:@"ImgurSecret"];
		if (key && secret)
			accessToken = [[OAToken alloc] initWithKey:key secret:secret];
	}
	if (accessToken)
		[self performUploadWithToken:data];
	else
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
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* key = [defaults stringForKey:@"ImgurKey"];
	NSString* secret = [defaults stringForKey:@"ImgurSecret"];
	if (!key || !secret)
		return false;

	accessToken = [[OAToken alloc] initWithKey:key secret:secret];
	
	return accessToken != nil;
}

- (void)linkAccount:(id)delegate withSelector:(SEL)finishSelector {	
	// create the url and request
    
    linkAccountDelegate = delegate;
    linkAccountSelector = finishSelector;
    
	NSURL* url = [NSURL URLWithString:@"https://api.imgur.com/oauth/request_token"];
	OAConsumer* consumer = [[OAConsumer alloc] initWithKey:imgurConsumerKey secret:imgurConsumerSecret];
	OAMutableURLRequest* request = [[OAMutableURLRequest alloc] initWithURL:url consumer:consumer token:nil realm:nil signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	
	// make the request
	OADataFetcher* fetcher = [[OADataFetcher alloc] init];
	[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
	
	// clean up
	[fetcher release];
	[request release];
	[consumer release];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		requestToken = [[OAToken alloc] initWithHTTPResponseBody:response];
		NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.imgur.com/oauth/authorize?oauth_token=%@", [requestToken key]]];
		[[NSWorkspace sharedWorkspace] openURL:url];
		[response release];
        [linkAccountDelegate performSelector:linkAccountSelector withObject:nil];
	}
	else
	{
        [linkAccountDelegate performSelector:linkAccountSelector withObject:@"Unable to get the request token from imgur"];
	}
    
    // Now that we've called back, clear the pointers
    linkAccountDelegate = nil;
    linkAccountSelector = nil;
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    [linkAccountDelegate performSelector:linkAccountSelector withObject:@"Unable to get the request token from imgur"];
    // Now that we've called back, clear the pointers
    linkAccountDelegate = nil;
    linkAccountSelector = nil;
}

- (void)authorizeAccount:(NSString*) verificationCode delegate:(id)delegate withSelector:(SEL)selector
{
    authorizeAccountDelegate = delegate;
    authorizeAccountSelector = selector;
	// create the url and request
	NSURL* url = [NSURL URLWithString:@"https://api.imgur.com/oauth/access_token"];
	OAConsumer* consumer = [[OAConsumer alloc] initWithKey:imgurConsumerKey secret:imgurConsumerSecret];
	[requestToken setVerifier:verificationCode];
	OAMutableURLRequest* request = [[OAMutableURLRequest alloc] initWithURL:url consumer:consumer token:requestToken realm:nil signatureProvider:nil];
	[request setHTTPMethod:@"POST"];
	
	// make the request
	OADataFetcher* fetcher = [[OADataFetcher alloc] init];
	[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(accessTokenTicket:didFinishWithData:) didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
	// clean up
	[fetcher release];
	[request release];
	[consumer release];
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
        NSLog(@"Successfully authenticated with Imgur");
		NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		accessToken = [[OAToken alloc] initWithHTTPResponseBody:response];
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:[accessToken key] forKey:@"ImgurKey"];
		[defaults setValue:[accessToken secret] forKey:@"ImgurSecret"];
		[response release];
        [authorizeAccountDelegate performSelector:authorizeAccountSelector withObject:nil];
	}
	else
	{
        NSLog(@"Unable to create access token for Imgur");
        [authorizeAccountDelegate performSelector:authorizeAccountSelector withObject:@"Invalid access token ticket"];

	}
    // Now that we've called back, clear the pointers
    authorizeAccountDelegate = nil;
    authorizeAccountSelector = nil;
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    [authorizeAccountDelegate performSelector:authorizeAccountSelector withObject:@"Unable to get access token"];
    // Now that we've called back, clear the pointers
    authorizeAccountDelegate = nil;
    authorizeAccountSelector = nil;

}

- (void)unlinkAccount
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"ImgurKey"];
	[defaults removeObjectForKey:@"ImgurSecret"];
	if (accessToken)
	{
		[accessToken release];
		accessToken = nil;
	}
}

@end
