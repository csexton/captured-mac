/*
 *  $Id: SCEvents.m 50 2009-12-04 22:36:01Z stuart $
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

#import "DirEvents.h"
#import "DirEvent.h"
#import "DirEventListenerProtocol.h"

@interface DirEvents (PrivateAPI)

- (void)_setupEventsStream;
static void _DirEventsCallBack(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]);

@end

static DirEvents *_sharedPathWatcher = nil;

@implementation DirEvents

@synthesize delegate;
@synthesize isWatchingPaths;
@synthesize ignoreEventsFromSubDirs;
@synthesize lastEvent;
@synthesize notificationLatency;
@synthesize watchedPaths;
@synthesize excludedPaths;

/**
 * Returns the shared singleton instance of SCEvents.
 */
+ (id)sharedPathWatcher
{
    @synchronized(self) {
        if (_sharedPathWatcher == nil) {
            [[self alloc] init];
        }
    }
    
    return _sharedPathWatcher;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (_sharedPathWatcher == nil) {
            _sharedPathWatcher = [super allocWithZone:zone];

            return _sharedPathWatcher;
        }
    }
    
	// On subsequent allocation attempts return nil
    return nil;
}

- (id)init
{
    if ((self = [super init])) {
        isWatchingPaths = NO;
        
        [self setNotificationLatency:3.0];
        [self setIgnoreEventsFromSubDirs:YES]; 
    }
    
    return self;
}

/**
 * The following base protocol methods are implemented to ensure
 * the singleton status of this class.
 */ 

- (id)copyWithZone:(NSZone *)zone { return self; }

- (id)retain { return self; }

- (NSUInteger)retainCount { return NSUIntegerMax; }

- (id)autorelease { return self; }

- (void)release { }

/**
 * Flushes the event stream synchronously by sending events that have already 
 * occurred but not yet delivered.
 */
- (BOOL)flushEventStreamSync
{
    if (!isWatchingPaths) return NO;
    
    FSEventStreamFlushSync(eventStream);
    
    return YES;
}

/**
 * Flushes the event stream asynchronously by sending events that have already 
 * occurred but not yet delivered.
 */
- (BOOL)flushEventStreamAsync
{
    if (!isWatchingPaths) return NO;
    
    FSEventStreamFlushAsync(eventStream);
    
    return YES;
}

/**
 * Starts watching the supplied array of paths for events on the current run loop.
 */
- (BOOL)startWatchingPaths:(NSMutableArray *)paths
{
    return [self startWatchingPaths:paths onRunLoop:[NSRunLoop currentRunLoop]];
}

/**
 * Starts watching the supplied array of paths for events on the supplied run loop.
 * A boolean value is returned to indicate the success of starting the stream. If 
 * there are no paths to watch or the stream is already running then false is
 * returned.
 */
- (BOOL)startWatchingPaths:(NSMutableArray *)paths onRunLoop:(NSRunLoop *)runLoop
{
    if (([paths count] == 0) || (isWatchingPaths)) return NO;
    
    [self setWatchedPaths:paths];
    [self _setupEventsStream];
    
    // Schedule the event stream on the supplied run loop
    FSEventStreamScheduleWithRunLoop(eventStream, [runLoop getCFRunLoop], kCFRunLoopDefaultMode);
    
    // Start the event stream
    FSEventStreamStart(eventStream);
    
    isWatchingPaths = YES;
    
    return YES;
}

/**
 * Stops the event stream from watching the set paths. A boolean value is returned
 * to indicate the success of stopping the stream. False is return if this method 
 * is called when the stream is not already running.
 */
- (BOOL)stopWatchingPaths
{
    if (!isWatchingPaths) return NO;
	    
    FSEventStreamStop(eventStream);
    FSEventStreamInvalidate(eventStream);
	
	if (eventStream) FSEventStreamRelease(eventStream), eventStream = nil;
    
    isWatchingPaths = NO;
    
    return YES;
}

- (NSString *)streamDescription
{
	if (!isWatchingPaths) return @"The event stream is not running. Start it by calling: startWatchingPaths:";
	
	NSString *desc = (NSString *)FSEventStreamCopyDescription(eventStream);
	NSString *ret = [NSString stringWithString:desc];
	[desc release]; // Added because Instruments compalined about leak. Otherwise I would just return desc
	return ret;
}

/**
 * Provides the string used when printing this object in NSLog, etc. Useful for
 * debugging purposes.
 */
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ { watchedPaths = %@, excludedPaths = %@ } >", [self className], watchedPaths, excludedPaths];
}

/**
 * dealloc
 */
- (void)dealloc
{
	delegate = nil;
	
	// Stop the event stream if it's still running
	if (isWatchingPaths) [self stopWatchingPaths];
        
	[lastEvent release], lastEvent = nil;
    [watchedPaths release], watchedPaths = nil;
    [excludedPaths release], excludedPaths = nil;
    
    [super dealloc];
}

@end

@implementation DirEvents (PrivateAPI)

/**
 * Constructs the events stream.
 */
- (void)_setupEventsStream
{
    FSEventStreamContext callbackInfo;
	
	callbackInfo.version = 0;
	callbackInfo.info    = (void*)self;
	callbackInfo.retain  = NULL;
	callbackInfo.release = NULL;
	callbackInfo.copyDescription = NULL;
	
	if (eventStream) FSEventStreamRelease(eventStream);
    
    eventStream = FSEventStreamCreate(kCFAllocatorDefault, &_DirEventsCallBack, &callbackInfo, ((CFArrayRef)watchedPaths), kFSEventStreamEventIdSinceNow, notificationLatency, kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagWatchRoot);
}

/**
 * FSEvents callback function. For each event that occurs an instance of SCEvent
 * is created and passed to the delegate. The frequency at which this callback is
 * called depends upon the notification latency value. This callback is usually
 * called with more than one event and so multiple instances of SCEvent are created
 * and the delegate notified.
 */
static void _DirEventsCallBack(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
    NSUInteger i;
    BOOL shouldIgnore = NO;
    
    DirEvents *pathWatcher = (DirEvents *)clientCallBackInfo;
	    
    for (i = 0; i < numEvents; i++) 
	{
        /* Please note that we are estimating the date for when the event occurred 
         * because the FSEvents API does not provide us with it. This date however
         * should not be taken as the date the event actually occurred and more 
         * appropriatly the date for when it was delivered to this callback function.
         * Depending on what the notification latency is set to, this means that some
         * events may have very close event dates because this callback is only called 
         * once with events that occurred within the latency time.
         *
         * To get a more accurate date for when events occur, you could decrease the 
         * notification latency from its default value. This means that this callback 
         * will be called more frequently for events that just occur and reduces the
         * number of events that are subsequntly delivered during one of these calls.
         * The drawback to this approach however, is the increased resources required
         * calling this callback more frequently.
         */
        
        NSString *eventPath = [((NSArray *)eventPaths) objectAtIndex:i];
		
		// If present remove the path's trailing slash
		if ([eventPath hasSuffix:@"/"]) {
			eventPath = [eventPath substringToIndex:([eventPath length] - 1)];
		}
		
		if (![[pathWatcher watchedPaths] containsObject:eventPath]) {
			shouldIgnore = YES;
		}
//		NSString *watchPath = [[pathWatcher watchedPaths] objectAtIndex:0];
//		if(![eventPath isEqualToString:watchPath]){
//			shouldIgnore = YES;
//		}
	
//        NSMutableArray *excludedPaths = [pathWatcher excludedPaths];
//        
//        //Check to see if the event should be ignored if it's path is in the exclude list
//        if ([excludedPaths containsObject:eventPath]) {
//            shouldIgnore = YES;
//        }
//        else {
//            // If we did not find an exact match in the exclude list and we are to ignore events from
//            // sub-directories then see if the exclude paths match as a prefix of the event path.
//            if ([pathWatcher ignoreEventsFromSubDirs]) {
//                for (NSString *path in [pathWatcher excludedPaths]) {
//                    if ([[(NSArray *)eventPaths objectAtIndex:i] hasPrefix:path]) {
//                        shouldIgnore = YES;
//                        break;
//                    }
//                }
//            }
//        }
    
        if (!shouldIgnore) {
			
            DirEvent *event = [DirEvent eventWithEventId:eventIds[i] eventPath:eventPath eventFlag:eventFlags[i]];
                
            if ([[pathWatcher delegate] conformsToProtocol:@protocol(DirEventListenerProtocol)]) {
                [[pathWatcher delegate] pathWatcher:pathWatcher eventOccurred:event];
            }
                
            if (i == (numEvents - 1)) {
                [pathWatcher setLastEvent:event];
            }
        }
		[eventPath release];
    }
}

@end
