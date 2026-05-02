#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAction.h>

@interface ASTextNode : NSObject
@end

// ======================= UILabel =======================

%hook UILabel

- (void)setText:(NSString *)text {
    if (text.length > 0) {
        %orig(@"TEST_LABEL 😈");
    } else {
        %orig;
    }
}

%end


// ======================= UITextView =======================

%hook UITextView

- (void)setText:(NSString *)text {
    if (text.length > 0) {
        %orig(@"TEST_TEXTVIEW 😈");
    } else {
        %orig;
    }
}

%end


// ======================= ASTextNode =======================

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


// ======================= UIAction =======================

%hook UIAction

+ (instancetype)actionWithTitle:(NSString *)title
                         image:(id)image
                    identifier:(id)identifier
                       handler:(void (^)(id))handler {

    // обязательно передаём аргументы в %orig
    UIAction *action = %orig(title, image, identifier, handler);

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