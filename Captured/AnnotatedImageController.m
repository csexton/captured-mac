//
//  AnnotatedImageController.m
//  Captured
//
//  Created by Christopher Sexton on 9/10/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "AnnotatedImageController.h"


@implementation AnnotatedImageController

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    // Initialization code here.
  }
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
  annotatedImageView.brushColor = colorWell.color;
  [self.window setLevel:NSModalPanelWindowLevel];
  [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
  //    [self.window setBackgroundColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.7]];
}

- (BOOL)windowShouldClose:(id)sender{
  // This was great, but didn't work with ARC
  // http://www.cocoabuilder.com/archive/cocoa/304428-release-nswindowcontroller-after-the-window-is-closed.html
  //    [self autorelease];
  //[AppDelegate removeAnnotatedWindow: self];
  return YES;
}



- (void)setImageAndShowWindow:(NSImage*) image {
  NSRect frame = [self.window frame];
  CGFloat imgX = 0;
  CGFloat minWidth = 340;
  frame.size.height = image.size.height + /* Button Bar Height */ 50 + /* Window Frame (20 for full title bar) */ 20;
  if (image.size.width < minWidth) {
    frame.size.width = minWidth; // Minimum width of image
    imgX = (minWidth/2) - (image.size.width/2); // Center the image
  } else {
    frame.size.width = image.size.width+1;
  }
  
  [self.window setFrame: frame display: YES animate: NO];
  [self.window center];
  
  [annotatedImageView setFrame: NSMakeRect(imgX, /* Button Bar Height */ 50, image.size.width+2, image.size.height)];
  [annotatedImageView setImage:image];
  [self useArrow:nil];
  
  // Show the window
  [[self window] makeKeyAndOrderFront:self];
  
}

-(IBAction)brushColorWellChanged:(id)sender{
  
  annotatedImageView.brushColor = colorWell.color;
}


-(IBAction)segmentedControlClicked:(id)sender{
  int selectedSegment = [sender selectedSegment];
  int clickedSegmentTag = [[sender cell] tagForSegment:selectedSegment];
  switch (clickedSegmentTag) {
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
-(IBAction)useArrow:(id)sender{
  [annotatedImageView selectArrowTool];
  [colorWell setHidden:YES];
  
  brushButton.state = NSOffState;
  highlighterButton.state = NSOffState;
}

-(IBAction)useBrush:(id)sender{
  [annotatedImageView selectBrushTool];
  [colorWell setHidden:NO];
  
  arrowButton.state = NSOffState;
  highlighterButton.state = NSOffState;
}
-(IBAction)useHighlighter:(id)sender{
  [annotatedImageView selectHighlighterTool];
  [colorWell setHidden:YES];
  
  arrowButton.state = NSOffState;
  brushButton.state = NSOffState;
  
}
-(IBAction)closeButton:(id)sender{
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSSSSS"];
  NSDate *now = [[NSDate alloc] init];
  NSString *timestamp = [dateFormat stringFromDate:now];
  NSString* path = [NSString stringWithFormat:@"%@captured-%@.png", NSTemporaryDirectory(), timestamp];
  
  NSLog(@"Saving Annotated Image to %@", path);
  
  [annotatedImageView saveViewToFile:path];
  
  [self close];
  
  NSLog(@"TODO : Close and process file");
  //[AppDelegate processFileEvent:path];
  
  //[self.window orderOut:nil]; // to hide it
  //[window makeKeyAndOrderFront:nil]; // to show it
}

-(IBAction)undoButton:(id)sender{
  [annotatedImageView undoDraw];
}

@end
