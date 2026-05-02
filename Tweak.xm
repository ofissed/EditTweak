#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ASTextNode : NSObject
@end

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


%hook ASTextNode

- (void)setAttributedText:(id)text {
    if ([text isKindOfClass:[NSAttributedString class]]) {
        NSString *str = [text respondsToSelector:@selector(string)] ? [text string] : @"";
        if (str.length > 0) {
            NSLog(@"[ASTextNode] %@ | %@", str, NSStringFromClass([self class]));
        }
    }
    %orig;
}

%end


%ctor {
    NSLog(@"[EditTweak] Logger loaded safely");
}