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
    IBOutlet NSButton *brushButton;
    IBOutlet NSButton *highlighterButton;
    IBOutlet NSButton *arrowButton;

}
- (void)setImageAndShowWindow:(NSImage*) image;

-(IBAction)useBrush:(id)sender;
-(IBAction)useArrow:(id)sender;
-(IBAction)useHighlighter:(id)sender;
-(IBAction)closeButton:(id)sender;

@end
