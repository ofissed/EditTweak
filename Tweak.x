// Telegram Edit Any Message Tweak
// Простой твик для демонстрации

#import <UIKit/UIKit.h>

// Хук в UIApplication для проверки что твик загружен
%hook UIApplication

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;
    
    // Показываем уведомление что твик загружен
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"EditTweak" 
        message:@"Твик успешно загружен!\n\nДля полной функциональности нужно найти правильные классы Telegram через Flex 3." 
        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction 
        actionWithTitle:@"OK" 
        style:UIAlertActionStyleDefault 
        handler:nil];
    
    [alert addAction:okAction];
    
    // Показываем через 2 секунды после запуска
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC) {
            [rootVC presentViewController:alert animated:YES completion:nil];
        }
    });
}

%end

// Конструктор
%ctor {
    NSLog(@"[EditTweak] Loaded successfully!");
}
