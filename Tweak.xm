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

	if (thumbnailView == nil) {
	    thumbnailView = panGestureRecognizer.view;
	}

	CGPoint translatedPoint = [panGestureRecognizer translationInView:panGestureRecognizer.view.superview];

    if ((panGestureRecognizer.state == UIGestureRecognizerStateCancelled) || (panGestureRecognizer.state == UIGestureRecognizerStateFailed) || (panGestureRecognizer.state == UIGestureRecognizerStateEnded) || (panGestureRecognizer.state == UIGestureRecognizerStateRecognized)) {

	    [%c(ZMZoomViewController) checkLandscapeOrientation];

        if (isLandscape) {
            savedPositionLandscape = thumbnailView.center;
        }
        else {
            savedPositionPortrait = thumbnailView.center;
        }

    }

    translatedPoint = CGPointMake(panGestureRecognizer.view.center.x+translatedPoint.x, panGestureRecognizer.view.center.y+translatedPoint.y);

    [panGestureRecognizer.view setCenter:translatedPoint];
    [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];

}

- (void)adjustThumbnailPositionWithAnimate:(BOOL)arg ResumeVideoStream:(BOOL)arg2{
	NSLog(@"[zoomTweak] -(void)adjustThumbnailPositionWithAnimate:(BOOL)%@ ResumeVideoStream:(BOOL)%@", arg ? @"YES" : @"NO", arg ? @"YES" : @"NO");

	[%c(ZMZoomViewController) checkLandscapeOrientation];

	if (counter < 9) {
	    counter++;
	    %orig;
	}
	else if (turnDisplay) {
		turnDisplay = NO;

		%orig;

	    // Move thumbnailView to savedPosition

		NSLog(@"[zoomTweak] isLandscape:%@", isLandscape ? @"YES" : @"NO");

		if (isLandscape && !CGPointEqualToPoint(savedPositionLandscape, {-1000.0,-1000.0})) {
			[thumbnailView setCenter:savedPositionLandscape];
		}
		else if (!CGPointEqualToPoint(savedPositionPortrait, {-1000.0,-1000.0})) {
			[thumbnailView setCenter:savedPositionPortrait];
		}
	}
	else if ((isLandscape && CGPointEqualToPoint(savedPositionLandscape, {-1000.0,-1000.0})) || (!isLandscape && CGPointEqualToPoint(savedPositionPortrait, {-1000.0,-1000.0}))) {
	    %orig;
	}

}

- (void)statusBarOrientationChangedNotification:(NSNotification *)notification {
	NSLog(@"[zoomTweak] Orientation Changed");

	turnDisplay = YES;

	%orig;
}

%new
+ (void)checkLandscapeOrientation {
	if (@available(iOS 13.0, *)) {
		UIWindow *firstWindow = [[[UIApplication sharedApplication] windows] firstObject];
		if (firstWindow == nil) { isLandscape = NO; }

		UIWindowScene *windowScene = firstWindow.windowScene;
		if (windowScene == nil){ isLandscape = NO; }

		isLandscape = UIInterfaceOrientationIsLandscape(windowScene.interfaceOrientation);
	} else {
		isLandscape = (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation));
	}
}

%end
