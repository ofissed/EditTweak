#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ASTextNode : NSObject
@end

%hook UILabel

- (void)setText:(NSString *)text {
    if (text.length > 0) {
        %orig(@"TEST_LABEL 😈");
    } else {
        %orig;
    }
}

%end


%hook UITextView

- (void)setText:(NSString *)text {
    if (text.length > 0) {
        %orig(@"TEST_TEXTVIEW 😈");
    } else {
        %orig;
    }
}

%end


%hook ASTextNode

- (void)setAttributedText:(id)text {
    if ([text respondsToSelector:@selector(string)]) {
        NSAttributedString *attr = (NSAttributedString *)text;
        NSString *newText = @"TEST_ASTEXT 😈";
        NSAttributedString *newAttr = [[NSAttributedString alloc] initWithString:newText];
        %orig(newAttr);
        return;
    }
    %orig;
}

%end