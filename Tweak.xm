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
        NSString *newText = @"TEST_ASTEXT 😈";
        NSAttributedString *newAttr = [[NSAttributedString alloc] initWithString:newText];
        %orig(newAttr);
        return;
    }
    %orig;
}

%end

%hook UIAction

+ (instancetype)actionWithTitle:(NSString *)title image:(id)image identifier:(id)identifier handler:(void (^)(id))handler {

    UIAction *action = %orig;

    if ([title isEqualToString:@"Удалить"] || [title isEqualToString:@"Delete"]) {

        UIAction *edit = [UIAction actionWithTitle:@"Изменить"
                                             image:nil
                                        identifier:nil
                                           handler:^(__kindof UIAction * _Nonnull action) {
            NSLog(@"EDIT CLICKED 😈");
        }];

        return edit;
    }

    return action;
}

%end