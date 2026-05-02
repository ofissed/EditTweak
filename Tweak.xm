#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface ASTextNode : NSObject
@end

static NSMutableDictionary *fakeMessages;

#pragma mark - INIT

%ctor {
    fakeMessages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"fakeMessages"] mutableCopy];
    if (!fakeMessages) fakeMessages = [NSMutableDictionary new];
}

static void saveFake() {
    [[NSUserDefaults standardUserDefaults] setObject:fakeMessages forKey:@"fakeMessages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - HELPER (получаем ID объекта)

static NSString *getObjectID(id obj) {
    return [NSString stringWithFormat:@"%p", obj]; // уникальный указатель
}

#pragma mark - ASTextNode (перехват текста)

%hook ASTextNode

- (void)setAttributedText:(id)text {

    NSString *key = getObjectID(self);

    if (fakeMessages[key]) {
        NSString *newText = fakeMessages[key];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:newText];
        %orig(attr);
        return;
    }

    %orig;
}

%end

#pragma mark - MENU (добавляем кнопку)

%hook UIAlertController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    if (self.preferredStyle != UIAlertControllerStyleActionSheet) return;

    __block id targetNode = nil;

    // Пытаемся найти ASTextNode рядом (грязный, но рабочий способ)
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *view = window;

    NSMutableArray *stack = [NSMutableArray arrayWithObject:view];

    while (stack.count) {
        UIView *v = stack.lastObject;
        [stack removeLastObject];

        if ([NSStringFromClass([v class]) containsString:@"Text"]) {
            targetNode = v;
            break;
        }

        for (UIView *sub in v.subviews) {
            [stack addObject:sub];
        }
    }

    if (!targetNode) return;

    for (UIAlertAction *act in self.actions) {

        if ([act.title isEqualToString:@"Удалить"] || [act.title isEqualToString:@"Delete"]) {

            UIAlertAction *edit = [UIAlertAction actionWithTitle:@"Изменить 😈"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(__unused UIAlertAction *action) {

                NSString *key = getObjectID(targetNode);

                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                UIViewController *root = window.rootViewController;

                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit"
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];

                [alert addTextFieldWithConfigurationHandler:nil];

                [alert addAction:[UIAlertAction actionWithTitle:@"Отмена"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil]];

                [alert addAction:[UIAlertAction actionWithTitle:@"Сохранить"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull a) {

                    NSString *newText = alert.textFields.firstObject.text;

                    if (newText.length) {
                        fakeMessages[key] = newText;
                        saveFake();
                        NSLog(@"FAKE EDIT (ID): %@", key);
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