#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSMutableDictionary *editedMessages;

%ctor {
    editedMessages = [NSMutableDictionary new];
    NSLog(@"[EditTweak] Loaded!");
}

// Хук UIAlertController для добавления кнопки
%hook UIAlertController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    if (self.preferredStyle != UIAlertControllerStyleActionSheet) return;
    
    // Ищем кнопку "Удалить"
    for (UIAlertAction *action in self.actions) {
        if ([action.title containsString:@"Удалить"] || [action.title containsString:@"Delete"]) {
            
            // Добавляем кнопку "Изменить"
            UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"✏️ Изменить"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *act) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Изменить сообщение"
                                                                               message:@"Введите новый текст"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                [alert addTextFieldWithConfigurationHandler:nil];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"Отмена"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil]];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"Сохранить"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *a) {
                    NSString *newText = alert.textFields.firstObject.text;
                    NSString *clipboardText = [UIPasteboard generalPasteboard].string;
                    
                    if (newText.length && clipboardText.length) {
                        editedMessages[clipboardText] = newText;
                        NSLog(@"[EditTweak] Saved: %@ -> %@", clipboardText, newText);
                    }
                }]];
                
                UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
                while (rootVC.presentedViewController) {
                    rootVC = rootVC.presentedViewController;
                }
                [rootVC presentViewController:alert animated:YES completion:nil];
            }];
            
            [self addAction:editAction];
            break;
        }
    }
}

%end

// Хук UILabel для подмены текста
%hook UILabel

- (void)setText:(NSString *)text {
    if (text && editedMessages[text]) {
        %orig(editedMessages[text]);
    } else {
        %orig;
    }
}

%end
