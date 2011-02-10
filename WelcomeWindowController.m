//
//  WelcomeWindowController.m
//  Captured
//
//  Created by Christopher Sexton on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WelcomeWindowController.h"


@implementation WelcomeWindowController
@synthesize window;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
        
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void) awakeFromNib
{
    //[window setBackgroundColor:[NSColor orangeColor]];
    //NSImage *theImage = [NSImage imageNamed:@"background"];
    NSImage *theImage = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WelcomeWindowBackground" ofType:@"png"]] retain];
    
    NSColor *theColor = [NSColor colorWithPatternImage:theImage];
    [window setBackgroundColor:theColor];
}

-(IBAction) closeWindowAction:(id) sender
{
    [window close];
}

//use this method to catch next note/prev note before View menu does
//thus avoiding annoying flicker and slow-down
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
	
	unsigned mods = [theEvent modifierFlags];
	
	BOOL isControlKeyPressed = (mods & NSControlKeyMask) != 0;
	BOOL isCommandKeyPressed = (mods & NSCommandKeyMask) != 0;
	BOOL isShiftKeyPressed = (mods & NSShiftKeyMask) != 0;
    
	// Also catch Ctrl-J/-K to match the shortcuts of other apps
	if (isCommandKeyPressed) {
		
		// Determine the keyChar:
		unichar keyChar = ' '; 
		if (isCommandKeyPressed) {
			keyChar = [theEvent firstCharacter]; /*cannot use ignoringModifiers here as it subverts the Dvorak-Qwerty-CMD keyboard layout */
		}
		if (isControlKeyPressed) {
			keyChar = [theEvent firstCharacterIgnoringModifiers]; /* first gets '\n' when control key is set, so fall back to ignoringModifiers */
		}
		
		// Handle J and K for both Control and Command
		if ( keyChar == 'w' || keyChar == 'q' ) {
			[window close];
            return YES;
		}
        

	}
	
	return [super performKeyEquivalent:theEvent];
}



@end
