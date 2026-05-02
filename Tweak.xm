#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UILabel

- (void)setText:(NSString *)text {
    if (text && text.length > 0) {
        NSLog(@"[UILabel] %@ | %@", text, NSStringFromClass([self class]));
    }
    %orig;
}

%end


%hook UITextView

- (void)setText:(NSString *)text {
    if (text && text.length > 0) {
        NSLog(@"[UITextView] %@ | %@", text, NSStringFromClass([self class]));
    }
    %orig;
}

%end


%hook NSObject

- (void)setAttributedText:(NSAttributedString *)text {
    if (text.string.length > 0) {
        NSLog(@"[ATTR] %@ | %@", text.string, NSStringFromClass([self class]));
    }
    %orig;
}

%end


%ctor {
    NSLog(@"[EditTweak] Logger loaded!");
}