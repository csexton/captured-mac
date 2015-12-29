//
//  AnnotatedImageController.h
//  Captured
//
//  Created by Christopher Sexton on 9/10/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AnnotatedImageView.h"

@interface AnnotatedImageController : NSWindowController <NSWindowDelegate> {
  @private

  IBOutlet AnnotatedImageView *annotatedImageView;
  IBOutlet NSButton *brushButton;
  IBOutlet NSButton *highlighterButton;
  IBOutlet NSButton *arrowButton;
  IBOutlet NSColorWell *colorWell;
  IBOutlet NSSegmentedControl *segmentedControl;
  IBOutlet NSView *toolBar;
}

@property dispatch_semaphore_t semaphore;
@property NSString *imageFilePath;
@property BOOL userCanceled;
- (void)showWindowAndAnnotateImageInPlace:(NSString *)path;

- (IBAction)useBrush:(id)sender;
- (IBAction)useArrow:(id)sender;
- (IBAction)useHighlighter:(id)sender;
- (IBAction)closeButton:(id)sender;
- (IBAction)undoButton:(id)sender;
- (IBAction)segmentedControlClicked:(id)sender;
- (IBAction)brushColorWellChanged:(id)sender;


@end