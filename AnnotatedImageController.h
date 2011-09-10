//
//  AnnotatedImageController.h
//  Captured
//
//  Created by Christopher Sexton on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AnnotatedImageView.h"
@interface AnnotatedImageController : NSWindowController{
@private
    
    IBOutlet AnnotatedImageView *annotateImageView;

}
- (void)setImage:(NSImage*) image;

-(IBAction)useBrush:(id)sender;
-(IBAction)useArrow:(id)sender;

@end
