#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UILabel

- (void)setText:(NSString *)text {
    if ([text isKindOfClass:[NSString class]] && text.length > 0) {
        NSLog(@"[UILabel] %@ | %@", text, NSStringFromClass([self class]));
    }
    %orig;
}

%end


%hook UITextView

- (void)setText:(NSString *)text {
    if ([text isKindOfClass:[NSString class]] && text.length > 0) {
        NSLog(@"[UITextView] %@ | %@", text, NSStringFromClass([self class]));
    }
    %orig;
}

%end


%hook ASTextNode

- (void)setAttributedText:(NSAttributedString *)text {
    if ([text isKindOfClass:[NSAttributedString class]] && text.string.length > 0) {
        NSLog(@"[ASTextNode] %@ | %@", text.string, NSStringFromClass([self class]));
    }
    %orig;
}

%end


%ctor {
    NSLog(@"[EditTweak] Safe logger loaded");
}