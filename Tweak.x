// Telegram Edit Any Message Tweak
// Базовый твик для тестирования

#import <Foundation/Foundation.h>

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    NSLog(@"[EditTweak] SpringBoard hook works!");
}

%end

%ctor {
    NSLog(@"[EditTweak] Tweak loaded successfully!");
}
