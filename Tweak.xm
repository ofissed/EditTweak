#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ASTextNode : NSObject
@end

@interface UIAction : NSObject
+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image identifier:(NSString *)identifier handler:(void (^)(UIAction *))handler;
@end

@interface UIMenu : NSObject
+ (instancetype)menuWithTitle:(NSString *)title children:(NSArray *)children;
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

%hook UIMenu

+ (instancetype)menuWithTitle:(NSString *)title children:(NSArray *)children {
    NSMutableArray *newChildren = [children mutableCopy];
    
    // Добавляем кнопку "Изменить"
    UIAction *editAction = [UIAction actionWithTitle:@"✏️ Изменить"
                                               image:nil
                                          identifier:@"com.edit.message"
                                             handler:^(__kindof UIAction * _Nonnull action) {
        NSLog(@"[EditTweak] EDIT CLICKED! 😈");
        
        // Показываем алерт для ввода текста
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Изменить сообщение"
                                                                       message:@"Введите новый текст"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Новый текст";
        }];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Сохранить"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
            NSString *newText = alert.textFields.firstObject.text;
            NSLog(@"[EditTweak] New text: %@", newText);
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отмена"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        [alert addAction:saveAction];
        [alert addAction:cancelAction];
        
        // Показываем алерт
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (rootVC.presentedViewController) {
            rootVC = rootVC.presentedViewController;
        }
        [rootVC presentViewController:alert animated:YES completion:nil];
    }];
    
    // Добавляем в начало меню
    [newChildren insertObject:editAction atIndex:0];
    
    return %orig(title, newChildren);
}

%end