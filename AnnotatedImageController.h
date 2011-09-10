//
//  AnnotatedImageController.h
//  Captured
//
//  Created by Christopher Sexton on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AnnotateImageView.h"
@interface AnnotatedImageController : NSWindowController{
@private
    
    IBOutlet AnnotateImageView *annotateImageView;

}

-(IBAction)useBrush:(id)sender;
-(IBAction)useArrow:(id)sender;

@end
