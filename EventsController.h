/*
 *  $Id: Controller.h 34 2009-09-01 00:42:14Z stuart $
 *
 *  SCEvents
 *
 *  Copyright (c) 2009 Stuart Connolly
 *  http://stuconnolly.com/projects/source-code/
 *
 *  Permission is hereby granted, free of charge, to any person
 *  obtaining a copy of this software and associated documentation
 *  files (the "Software"), to deal in the Software without
 *  restriction, including without limitation the rights to use,
 *  copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following
 *  conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 * 
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 *  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 *  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 *  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *  OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "DirEventListenerProtocol.h"
#import "ImgurUploader.h"
#import "SFTPUploader.h"
#import "CloudUploader.h"
#import "DropboxUploader.h"

@interface EventsController : NSObject <DirEventListenerProtocol> {
    NSString *screenCapturePrefix;
    NSString *screenCaptureDir;
	NSMutableSet *history;
	ImgurUploader *imgur;
	SFTPUploader* sftpUploader;
	CloudUploader* cloudUploader;
	DropboxUploader* dropboxUploader;
}

@property (readwrite, retain) NSString *screenCapturePrefix;
@property (readwrite, retain) NSString *screenCaptureDir;
@property (readwrite, retain) NSMutableSet *history;
@property (readwrite, retain) ImgurUploader *imgur;
@property (readwrite, retain) SFTPUploader* sftpUploader;
@property (readwrite, retain) CloudUploader* cloudUploader;
@property (readwrite, retain) DropboxUploader* dropboxUploader;

- (void)setupEventListener;
- (void)processFile: (NSString*)file;
- (NSArray *)findFilesWithPrefix: (NSString*)prefix inDir:(NSString*)basepath;

@end
