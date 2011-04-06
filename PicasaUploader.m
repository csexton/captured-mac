//
//  PicasaUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 4/3/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "Utilities.h"
#import "GData/GDataEntryPhoto.h"
#import "GData/GDataEntryPhotoAlbum.h"
#import "GData/GDataFeedPhotoUser.h"
#import "GData/GDataServiceGooglePhotos.h"
#import "GData/GDataFeedPhotoAlbum.h"
#import "CapturedAppDelegate.h"
#import "PicasaUploader.h"

@implementation PicasaUploader

- (void) setPhotoFeed:(GDataFeedPhotoAlbum*) feed {
	[photoFeed autorelease];
	photoFeed = [feed retain];
}

- (GDataFeedPhotoAlbum*) photoFeed {
	return photoFeed;
}

- (GDataServiceGooglePhotos *)googlePhotosService {
	
	static GDataServiceGooglePhotos* service = nil;
	
	if (!service) {
		service = [[GDataServiceGooglePhotos alloc] init];
		
		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
	}
	
	// update the username/password each time the service is requested
	NSString *username = @"jorge.velazquez@gmail.com";
	NSString *password = @"password";
	if ([username length] && [password length]) {
		[service setUserCredentialsWithUsername:username
									   password:password];
	} else {
		[service setUserCredentialsWithUsername:nil
									   password:nil];
	}

	return service;
}

// photo list fetch callback
- (void)photosTicket:(GDataServiceTicket *)ticket
    finishedWithFeed:(GDataFeedPhotoAlbum *)feed
               error:(NSError *)error {
	[self setPhotoFeed:feed];
}

- (void) loadAlbum:(NSString*) albumName {
	NSURL *feedURL = [GDataServiceGooglePhotos photoFeedURLForUserID:@"jorge.velazquez@gmail.com"
															 albumID:nil
														   albumName:albumName
															 photoID:nil
																kind:nil
															  access:nil];
	
	// make service tickets call back into our upload progress selector
	GDataServiceGooglePhotos *service = [self googlePhotosService];
	
	[service fetchFeedWithURL:feedURL
					 delegate:self
			didFinishSelector:@selector(photosTicket:finishedWithFeed:error:)];
}

- (void)addPhotoTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryPhoto *)photoEntry
                 error:(NSError *)error {
	
	if (error == nil) {
		// tell the user that the add worked
		NSLog(@"Success!");
	} else {
		// upload failed
		NSLog(@"Add failed: %@", [error description]);
	}
}

- (void)uploadFile:(NSString*)sourceFile
{
	if (!photoFeed) {
		// TODO: before we get here, we should create an album if the user didn't specify one
		return;
	}
	
	// generate a unique filename
	NSString* tempNam = [Utilities createUniqueFilename];
	
	// create the photo service object
	NSData *photoData = [NSData dataWithContentsOfFile:sourceFile];
	if (photoData) {
		
		// make a new entry for the photo
		GDataEntryPhoto *newEntry = [GDataEntryPhoto photoEntry];
		
		// set a title, description, and timestamp
		[newEntry setTitleWithString:tempNam];
		[newEntry setPhotoDescriptionWithString:@"Uploaded by Captured for Mac"];
		[newEntry setTimestamp:[GDataPhotoTimestamp timestampWithDate:[NSDate date]]];
		
		// attach the NSData and set the MIME type for the photo
		[newEntry setPhotoData:photoData];
		
		NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:sourceFile
												   defaultMIMEType:@"image/png"];
		[newEntry setPhotoMIMEType:mimeType];
		
		// the slug is just the upload file's filename
		[newEntry setUploadSlug:sourceFile];
		
		// make service tickets call back into our upload progress selector
		GDataServiceGooglePhotos *service = [self googlePhotosService];
		
		NSURL* feedURL = [[photoFeed uploadLink] URL];
		
		// insert the entry into the album feed
		GDataServiceTicket *ticket;
		ticket = [service fetchEntryByInsertingEntry:newEntry
										  forFeedURL:feedURL
											delegate:self
								   didFinishSelector:@selector(addPhotoTicket:finishedWithEntry:error:)];
	} else {
	}

}

- (NSString*)testConnection
{
	NSString* testResponse = nil;

	return testResponse;
}

@end
