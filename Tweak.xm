// Telegram Edit Any Message Tweak (test)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    NSLog(@"[EditTweak] SpringBoard hook works!");
}

%end

%ctor {
    NSLog(@"[EditTweak] Tweak loaded successfully!");
}