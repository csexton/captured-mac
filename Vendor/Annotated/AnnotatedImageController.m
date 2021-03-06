//
//  AnnotatedImageController.m
//  Captured
//
//  Created by Christopher Sexton on 9/10/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "AnnotatedImageController.h"


@implementation AnnotatedImageController

- (id)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  if (self) {
    // Initialization code here.
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];

  self.userCanceled = YES;

  // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
  annotatedImageView.brushColor = colorWell.color;
  [self.window
   setLevel:NSModalPanelWindowLevel];
  [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
}

- (BOOL)windowShouldClose:(id)sender {
  dispatch_semaphore_signal(self.semaphore);
  return YES;
}

- (void)showWindowAndAnnotateImageInPlace:(NSString *)path {
  self.imageFilePath = path;
  NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];

  NSRect frame = [self.window frame];
  CGFloat imgX = 0;
  CGFloat minWidthOfImage = 340;
  frame.size.height = image.size.height + /* Button Bar Height */ 50 + /* Window Frame (20 for full title bar) */ 20;
  if (image.size.width < minWidthOfImage) {
    frame.size.width = minWidthOfImage;
    imgX = (minWidthOfImage / 2) - (image.size.width / 2); // Center the image
  } else {
    frame.size.width = image.size.width + 1;
  }
  [self.window
   setFrame:frame
    display:YES
    animate:NO];
  [self.window center];

  [annotatedImageView setFrame:NSMakeRect(imgX, /* Button Bar Height */ 50, image.size.width + 2, image.size.height)];
  [annotatedImageView setImage:image];
  [self useArrow:nil];

  // Show the window
  [[self window] makeKeyAndOrderFront:self];
}

- (IBAction)brushColorWellChanged:(id)sender {
  annotatedImageView.brushColor = colorWell.color;
}

- (IBAction)segmentedControlClicked:(id)sender {
  long selectedSegment = [sender selectedSegment];
  long clickedSegmentTag = [[sender cell] tagForSegment:selectedSegment];
  switch (clickedSegmentTag)
  {
    case 0:
      [self useArrow:nil];
      break;

    case 1:
      [self useHighlighter:nil];
      break;

    case 2:
      [self useBrush:nil];
      break;

    default:
      break;
  }
}

- (IBAction)useArrow:(id)sender {
  [annotatedImageView selectArrowTool];
  [colorWell setHidden:YES];

  brushButton.state = NSOffState;
  highlighterButton.state = NSOffState;
}

- (IBAction)useBrush:(id)sender {
  [annotatedImageView selectBrushTool];
  [colorWell setHidden:NO];

  arrowButton.state = NSOffState;
  highlighterButton.state = NSOffState;
}

- (IBAction)useHighlighter:(id)sender {
  [annotatedImageView selectHighlighterTool];
  [colorWell setHidden:YES];

  arrowButton.state = NSOffState;
  brushButton.state = NSOffState;
}

- (IBAction)closeButton:(id)sender {
  self.userCanceled = NO;

  NSLog(@"Saving Annotated Image to %@", self.imageFilePath);

  [annotatedImageView saveViewToFile:self.imageFilePath];

  [self close];

  dispatch_semaphore_signal(self.semaphore);
}

- (IBAction)undoButton:(id)sender {
  [annotatedImageView undoDraw];
}

@end