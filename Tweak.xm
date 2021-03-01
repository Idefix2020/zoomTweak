#import "Tweak.h"

#ifdef DEBUG
#define ALERT(...) do {																\
NSString *alertString = [NSString stringWithFormat:__VA_ARGS__];					\
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Idefix2020 Debug Alert" 	\
	message:alertString																\
	delegate:nil 																	\
	cancelButtonTitle:@"OK" 														\
	otherButtonTitles:nil];															\
[alert show];																		\
} while(0)
#else
#define ALERT(...)
#endif

int counter = 0;
BOOL isLandscape = NO;
CGPoint savedPositionPortrait = {-1000.0,-1000.0};
CGPoint savedPositionLandscape = {-1000.0,-1000.0};
BOOL turnDisplay = NO;
UIView *thumbnailView = nil;

%hook ZMZoomViewController

- (void)handledragThumbnailViewGesture:(UIPanGestureRecognizer*)panGestureRecognizer { // arg is a UIPanGestureRecognizer
	// ALERT(@"handledragThumbnailViewGesture:(id)%@",panGestureRecognizer);

	if (thumbnailView == nil) {
	    thumbnailView = panGestureRecognizer.view;
	}

	CGPoint translatedPoint = [panGestureRecognizer translationInView:panGestureRecognizer.view.superview];

    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // CGFloat firstX = panGestureRecognizer.view.center.x;
        // CGFloat firstY = panGestureRecognizer.view.center.y;
    }

    NSLog(@"[zoomTweak] state: %ld", panGestureRecognizer.state);

    if ((panGestureRecognizer.state == UIGestureRecognizerStateCancelled) || (panGestureRecognizer.state == UIGestureRecognizerStateFailed) || (panGestureRecognizer.state == UIGestureRecognizerStateEnded) || (panGestureRecognizer.state == UIGestureRecognizerStateRecognized)) {
        CGPoint finalPosition = panGestureRecognizer.view.center;

        NSLog(@"[zoomTweak] view: %@", panGestureRecognizer.view);        
        NSLog(@"[zoomTweak] finalPosition: %@", NSStringFromCGPoint(finalPosition));

        if (@available(iOS 13.0, *)) {
        	UIWindow *firstWindow = [[[UIApplication sharedApplication] windows] firstObject];
        	if (firstWindow == nil) { isLandscape = NO; }

        	UIWindowScene *windowScene = firstWindow.windowScene;
        	if (windowScene == nil){ isLandscape = NO; }

        	isLandscape = UIInterfaceOrientationIsLandscape(windowScene.interfaceOrientation);
        } else {
        	isLandscape = (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation));
        }

        NSLog(@"[zoomTweak] isLandscape:%@", isLandscape ? @"YES" : @"NO");

        if (!isLandscape) {
            savedPositionPortrait = finalPosition;
        }
        else {
            savedPositionLandscape = finalPosition;
        }

    }

    translatedPoint = CGPointMake(panGestureRecognizer.view.center.x+translatedPoint.x, panGestureRecognizer.view.center.y+translatedPoint.y);

    [panGestureRecognizer.view setCenter:translatedPoint];
    [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];

	// %orig;
}

- (void)adjustThumbnailPositionWithAnimate:(BOOL)arg {
	NSLog(@"[zoomTweak] -(void)adjustThumbnailPositionWithAnimate:(BOOL)%@", arg ? @"YES" : @"NO");

	if (counter < 10) {
	    counter++;
	    %orig;
	}
	else {
	    if (turnDisplay) {
	        turnDisplay = NO;

	        %orig;

	        // Move thumbnailView to savedPosition
	        if (@available(iOS 13.0, *)) {
	        	UIWindow *firstWindow = [[[UIApplication sharedApplication] windows] firstObject];
	        	if (firstWindow == nil) { isLandscape = NO; }

	        	UIWindowScene *windowScene = firstWindow.windowScene;
	        	if (windowScene == nil){ isLandscape = NO; }

	        	isLandscape = UIInterfaceOrientationIsLandscape(windowScene.interfaceOrientation);
	        } else {
	        	isLandscape = (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation));
	        }

	        NSLog(@"[zoomTweak] isLandscape:%@", isLandscape ? @"YES" : @"NO");

	        if (!isLandscape && !CGPointEqualToPoint(savedPositionPortrait, {-1000.0,-1000.0})) {
	        	[thumbnailView setCenter:savedPositionPortrait];
	        	NSLog(@"[zoomTweak] savedPositionPortrait:%@", NSStringFromCGPoint(savedPositionPortrait));
	        }
	        else if (!CGPointEqualToPoint(savedPositionLandscape, {-1000.0,-1000.0})) {
	        	[thumbnailView setCenter:savedPositionLandscape];
	        	NSLog(@"[zoomTweak] savedPositionLandscape:%@", NSStringFromCGPoint(savedPositionLandscape));
	        }
	    }
	}

}

- (void)statusBarOrientationChangedNotification:(NSNotification *)notification {
	NSLog(@"[zoomTweak] Notification: %@", notification);

	turnDisplay = YES;

	%orig;
}

%end

%hook ZMVideoViewController

- (void)viewDidLoad {
	// thumbnailView = MSHookIvar<UIView *>(self, "thumbnailView");

	// [thumbnailView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];

	%orig;
}

%end

%hook ZMShareViewController

- (void)updateThumbnailViewFrame {
	NSLog(@"[zoomTweak] -(void)updateThumbnailViewFrame");

	%orig;
}

%end
