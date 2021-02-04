#import "Tweak.h"

%hook ZMZoomViewController

- (void)handledragThumbnailViewGesture:(id)arg {
	%log;

	%orig;
}

%end
