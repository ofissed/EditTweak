#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ASTextNode : NSObject
@end

// Фейковое хранилище
static NSMutableDictionary *fakeMessages;

%ctor {
    fakeMessages = [NSMutableDictionary new];
}

#pragma mark - FAKE TEXT

%hook ASTextNode

- (void)setAttributedText:(id)text {

    if ([text respondsToSelector:@selector(string)]) {

        NSString *original = [text string];

        if (original && fakeMessages[original]) {
            NSString *newText = fakeMessages[original];
            NSAttributedString *attr = [[NSAttributedString alloc] initWithString:newText];
            %orig(attr);
            return;
        }
    }

    %orig;
}

%end

#pragma mark - MENU (UIAlertController перехват)

%hook UIAlertController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    // Проверяем, что это action sheet (меню как у тебя на скрине)
    if (self.preferredStyle != UIAlertControllerStyleActionSheet) return;

    // Ищем кнопку "Удалить"
    for (UIAlertAction *act in self.actions) {

        if ([act.title isEqualToString:@"Удалить"] || [act.title isEqualToString:@"Delete"]) {

            // Добавляем кнопку "Изменить"
            UIAlertAction *edit = [UIAlertAction actionWithTitle:@"Изменить 😈"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(__unused UIAlertAction *action) {

                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                UIViewController *root = window.rootViewController;

                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit message"
                                                                               message:@"Введите новый текст"
                                                                        preferredStyle:UIAlertControllerStyleAlert];

                [alert addTextFieldWithConfigurationHandler:nil];

                [alert addAction:[UIAlertAction actionWithTitle:@"Отмена"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil]];

                [alert addAction:[UIAlertAction actionWithTitle:@"Сохранить"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull a) {

                    NSString *newText = alert.textFields.firstObject.text;
                    NSString *selected = [UIPasteboard generalPasteboard].string;

                    if (selected.length && newText.length) {
                        fakeMessages[selected] = newText;
                        NSLog(@"FAKE EDIT: %@ -> %@", selected, newText);
                    }

                }]];

                [root presentViewController:alert animated:YES completion:nil];
            }];

            [self addAction:edit];
            break;
        }
    }
}

%end