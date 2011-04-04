//
//  PicasaUploader.h
//  Captured for Mac
//
//  Created by Jorge Velázquez on 4/3/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GData/GDataFeedPhotoAlbum.h"
#import "GData/GDataFeedPhotoUser.h"
#import "AbstractUploader.h"

@interface PicasaUploader : AbstractUploader {
	GDataFeedPhotoAlbum* photoFeed;
}

- (void) setPhotoFeed:(GDataFeedPhotoAlbum*) feed;
- (GDataFeedPhotoAlbum*) photoFeed;
- (void) loadAlbum:(NSString*) albumName;

@end
