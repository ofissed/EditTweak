#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSMutableDictionary *editedMessages;
static NSString *lastLongPressedText = nil;

%ctor {
    editedMessages = [NSMutableDictionary new];
    NSLog(@"[EditTweak] Loaded!");
}

// Хук UILongPressGestureRecognizer для захвата текста при долгом нажатии
%hook UILongPressGestureRecognizer

- (void)setState:(UIGestureRecognizerState)state {
    %orig;
    
    if (state == UIGestureRecognizerStateBegan) {
        UIView *view = self.view;
        
        // Пытаемся найти текст в view
        if ([view isKindOfClass:[UILabel class]]) {
            lastLongPressedText = [(UILabel *)view text];
            NSLog(@"[EditTweak] Long press on UILabel: %@", lastLongPressedText);
        } else if ([view isKindOfClass:[UITextView class]]) {
            lastLongPressedText = [(UITextView *)view text];
            NSLog(@"[EditTweak] Long press on UITextView: %@", lastLongPressedText);
        } else {
            // Ищем UILabel или UITextView в subviews
            for (UIView *subview in view.subviews) {
                if ([subview isKindOfClass:[UILabel class]]) {
                    lastLongPressedText = [(UILabel *)subview text];
                    NSLog(@"[EditTweak] Long press found UILabel in subview: %@", lastLongPressedText);
                    break;
                } else if ([subview isKindOfClass:[UITextView class]]) {
                    lastLongPressedText = [(UITextView *)subview text];
                    NSLog(@"[EditTweak] Long press found UITextView in subview: %@", lastLongPressedText);
                    break;
                }
            }
        }
    }
}

%end

// Хук UIAlertController для добавления кнопки
%hook UIAlertController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    if (self.preferredStyle != UIAlertControllerStyleActionSheet) return;
    
    // Ищем кнопку "Удалить"
    BOOL hasDeleteButton = NO;
    for (UIAlertAction *action in self.actions) {
        if ([action.title containsString:@"Удалить"] || [action.title containsString:@"Delete"]) {
            hasDeleteButton = YES;
            break;
        }
    }
    
    if (!hasDeleteButton) return;
    
    // Проверяем, не добавили ли мы уже кнопку
    for (UIAlertAction *action in self.actions) {
        if ([action.title containsString:@"Изменить"]) {
            return; // Уже добавлена
        }
    }
    
    // Добавляем кнопку "Изменить"
    UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"✏️ Изменить"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *act) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Изменить сообщение"
                                                                       message:@"Введите новый текст"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            // Предзаполняем текущий текст если есть
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
            
            // Fallback на clipboard если lastLongPressedText пустой
            if (!originalText || originalText.length == 0) {
                originalText = [UIPasteboard generalPasteboard].string;
            }
            
            if (newText.length && originalText.length) {
                editedMessages[originalText] = newText;
                NSLog(@"[EditTweak] Saved: %@ -> %@", originalText, newText);
                
                // Принудительно обновляем UI
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
    }];
    
    [self addAction:editAction];
}

%end

// Хук UILabel для подмены текста
%hook UILabel

- (void)setText:(NSString *)text {
    if (text && text.length > 0 && editedMessages[text]) {
        NSLog(@"[EditTweak] Replacing UILabel text: %@ -> %@", text, editedMessages[text]);
        %orig(editedMessages[text]);
    } else {
        %orig;
    }
}

- (void)didMoveToWindow {
    %orig;
    // Подписываемся на уведомления об обновлении
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(refreshText) 
                                                 name:@"EditTweakMessageUpdated" 
                                               object:nil];
}

%new
- (void)refreshText {
    NSString *currentText = self.text;
    if (currentText && editedMessages[currentText]) {
        [self setText:currentText];
    }
}

%end

// Хук UITextView для подмены текста
%hook UITextView

- (void)setText:(NSString *)text {
    if (text && text.length > 0 && editedMessages[text]) {
        NSLog(@"[EditTweak] Replacing UITextView text: %@ -> %@", text, editedMessages[text]);
        %orig(editedMessages[text]);
    } else {
        %orig;
    }
}

%end
