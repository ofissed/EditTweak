// Telegram Edit Any Message Tweak
// Базовый твик - просто логи

#import <Foundation/Foundation.h>

%ctor {
    NSLog(@"[EditTweak] Loaded in: %@", [[NSBundle mainBundle] bundleIdentifier]);
}
