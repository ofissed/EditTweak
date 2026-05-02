#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSMutableDictionary *editedMessages;
static NSString *lastLongPressedText = nil;

// Вспомогательная функция для поиска текста
static NSString* findTextInView(UIView *view) {
    if ([view isKindOfClass:[UILabel class]]) {
        return [(UILabel *)view text];
    }
    if ([view isKindOfClass:[UITextView class]]) {
        return [(UITextView *)view text];
    }
    
    for (UIView *subview in view.subviews) {
        NSString *text = findTextInView(subview);
        if (text && text.length > 0) return text;
    }
    return nil;
}

// Вспомогательная функция для показа диалога редактирования
static void showEditDialog(UIViewController *fromVC) {
    NSLog(@"[EditTweak] showEditDialog called");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Изменить сообщение"
                                                                   message:@"Введите новый текст"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        if (lastLongPressedText) {
            textField.text = lastLongPressedText;
        }
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Отмена"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Сохранить"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *a) {
        NSString *newText = alert.textFields.firstObject.text;
        NSString *originalText = lastLongPressedText;
        
        if (!originalText || originalText.length == 0) {
            originalText = [UIPasteboard generalPasteboard].string;
        }
        
        if (newText.length && originalText.length) {
            editedMessages[originalText] = newText;
            NSLog(@"[EditTweak] Saved edit: %@ -> %@", originalText, newText);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EditTweakMessageUpdated" object:nil];
            });
        }
    }]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    [rootVC presentViewController:alert animated:YES completion:nil];
}

%ctor {
    editedMessages = [NSMutableDictionary new];
    NSLog(@"[EditTweak] ===== TWEAK LOADED =====");
    
    // Создаем файл-маркер для проверки загрузки
    [@"TWEAK LOADED" writeToFile:@"/var/mobile/Documents/EditTweak_loaded.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Показываем alert при загрузке
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"EditTweak"
                                                                       message:@"Твик загружен!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (rootVC.presentedViewController) {
            rootVC = rootVC.presentedViewController;
        }
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

// Хук UILongPressGestureRecognizer для захвата текста
%hook UILongPressGestureRecognizer

- (void)setState:(UIGestureRecognizerState)state {
    %orig;
    
    if (state == UIGestureRecognizerStateBegan) {
        UIView *view = self.view;
        NSLog(@"[EditTweak] Long press detected on view: %@", NSStringFromClass([view class]));
        
        lastLongPressedText = findTextInView(view);
        if (lastLongPressedText) {
            NSLog(@"[EditTweak] Captured text: %@", lastLongPressedText);
        }
    }
}

%end

// Хук UIPasteboard для перехвата копирования
%hook UIPasteboard

- (void)setString:(NSString *)string {
    %orig;
    
    NSLog(@"[EditTweak] Text copied to clipboard: %@", string);
    
    // Проверяем что это копирование из долгого нажатия на сообщение
    // (lastLongPressedText должен быть установлен)
    if (lastLongPressedText && [string isEqualToString:lastLongPressedText]) {
        NSLog(@"[EditTweak] This is a message copy, showing edit dialog...");
        
        // Показываем диалог редактирования через 0.5 сек
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (rootVC.presentedViewController) {
                rootVC = rootVC.presentedViewController;
            }
            showEditDialog(rootVC);
        });
    } else {
        NSLog(@"[EditTweak] Regular copy, ignoring");
    }
}

%end

// Хук UIViewController для логирования
%hook UIViewController

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alert = (UIAlertController *)viewControllerToPresent;
        
        if (alert.preferredStyle == UIAlertControllerStyleActionSheet) {
            NSLog(@"[EditTweak] ActionSheet with actions:");
            for (UIAlertAction *action in alert.actions) {
                NSLog(@"[EditTweak]   - %@", action.title);
            }
        }
    }
    
    %orig;
}

%end

// Хук UILabel для подмены текста
%hook UILabel

- (void)setText:(NSString *)text {
    if (text && text.length > 0 && editedMessages[text]) {
        NSLog(@"[EditTweak] Replacing UILabel: %@ -> %@", text, editedMessages[text]);
        %orig(editedMessages[text]);
    } else {
        %orig;
    }
}

%end

// Хук UITextView для подмены текста
%hook UITextView

- (void)setText:(NSString *)text {
    if (text && text.length > 0 && editedMessages[text]) {
        NSLog(@"[EditTweak] Replacing UITextView: %@ -> %@", text, editedMessages[text]);
        %orig(editedMessages[text]);
    } else {
        %orig;
    }
}

%end
