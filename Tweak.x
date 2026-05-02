// Telegram Edit Any Message Tweak
// Позволяет локально редактировать любые сообщения

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Словарь для хранения отредактированных сообщений
static NSMutableDictionary *editedMessages = nil;

// Интерфейс для контекстного меню сообщения
%hook TGMenuSheetController

- (instancetype)initWithItemViews:(NSArray *)itemViews {
    self = %orig;
    
    if (self) {
        // Создаем кнопку "Изменить"
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [editButton setTitle:@"✏️ Изменить" forState:UIControlStateNormal];
        editButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [editButton addTarget:self action:@selector(customEditMessage:) forControlEvents:UIControlEventTouchUpInside];
        
        // Добавляем кнопку в меню
        NSMutableArray *newItems = [itemViews mutableCopy];
        [newItems insertObject:editButton atIndex:0];
    }
    
    return self;
}

%new
- (void)customEditMessage:(UIButton *)sender {
    // Показываем UI для редактирования
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Изменить сообщение"
                                                                   message:@"Введите новый т��кст (изменения только у вас)"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Новый текст сообщения";
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    }];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Сохранить"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        NSString *newText = textField.text;
        
        if (newText && newText.length > 0) {
            // Сохраняем отредактированный текст
            // Здесь нужно получить ID сообщения и сохранить
            if (!editedMessages) {
                editedMessages = [[NSMutableDictionary alloc] init];
            }
            
            // Получаем ID текущего сообщения (нужно адаптировать под структуру Telegram)
            NSString *messageId = @"temp_id"; // Заменить на реальный ID
            [editedMessages setObject:newText forKey:messageId];
            
            // Обновляем UI
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessages" object:nil];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отмена"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alert addAction:saveAction];
    [alert addAction:cancelAction];
    
    // Показываем alert
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [topController presentViewController:alert animated:YES completion:nil];
    
    // Закрываем меню
    [self dismissAnimated:YES];
}

%end

// Хук для отображения текста сообщения
%hook TGMessageViewModel

- (NSString *)text {
    NSString *originalText = %orig;
    
    // Проверяем, есть ли отредактированная версия
    if (editedMessages) {
        // Получаем ID сообщения
        NSString *messageId = [self valueForKey:@"_messageId"];
        if (messageId) {
            NSString *editedText = [editedMessages objectForKey:messageId];
            if (editedText) {
                return editedText;
            }
        }
    }
    
    return originalText;
}

%end

// Конструктор - инициализация при загрузке
%ctor {
    editedMessages = [[NSMutableDictionary alloc] init];
    
    // Загружаем сохраненные изменения из файла
    NSString *savePath = @"/var/mobile/Library/Preferences/com.yourname.editedmessages.plist";
    NSDictionary *saved = [NSDictionary dictionaryWithContentsOfFile:savePath];
    if (saved) {
        editedMessages = [saved mutableCopy];
    }
}

// Деструктор - сохранение при выгрузке
%dtor {
    // Сохраняем изменения в файл
    NSString *savePath = @"/var/mobile/Library/Preferences/com.yourname.editedmessages.plist";
    [editedMessages writeToFile:savePath atomically:YES];
}
