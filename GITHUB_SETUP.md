# Как использовать GitHub Actions для компиляции

## Быстрый старт

### 1. Создай репозиторий на GitHub

1. Зайди на https://github.com
2. Нажми "New repository" (зеленая кнопка)
3. Назови репозиторий, например: `telegram-edit-tweak`
4. Выбери "Public" или "Private"
5. НЕ добавляй README, .gitignore (у нас уже есть)
6. Нажми "Create repository"

### 2. Загрузи код на GitHub

Открой терминал (PowerShell/CMD) в папке с проектом:

```bash
# Инициализируй git
git init

# Добавь все файлы
git add .

# Сделай первый коммит
git commit -m "Initial commit"

# Добавь удаленный репозиторий (замени YOUR_USERNAME и REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git

# Загрузи код
git branch -M main
git push -u origin main
```

### 3. GitHub автоматически скомпилирует твик

После push:
1. Зайди в свой репозиторий на GitHub
2. Перейди во вкладку **Actions**
3. Увидишь процесс сборки (желтый кружок = идет, зеленая галочка = готово)
4. Подожди 2-3 минуты

### 4. Скачай .deb файл

1. Во вкладке **Actions** нажми на последний успешный build (зеленая галочка)
2. Прокрути вниз до раздела **Artifacts**
3. Скачай `TelegramEditAnyMessage.zip`
4. Распакуй - внутри будет .deb файл

### 5. Установи на iPhone

**Способ 1: Через Telegram**
- Отправь .deb файл себе в Telegram
- Открой на iPhone
- Нажми "Open in Filza"
- Нажми "Install"
- Respring

**Способ 2: Через облако**
- Загрузи .deb в Dropbox/Google Drive
- Скачай на iPhone
- Открой в Filza
- Установи

**Способ 3: Через USB**
- Используй 3uTools или iFunBox
- Перенеси файл в /var/mobile/Documents/
- Открой в Filza и установи

---

## Обновление твика

Когда изменишь код:

```bash
# Добавь изменения
git add .

# Сделай коммит
git commit -m "Описание изменений"

# Загрузи на GitHub
git push
```

GitHub автоматически пересоберет твик!

---

## Создание релиза (опционально)

Чтобы .deb автоматически прикреплялся к релизу:

```bash
# Создай тег версии
git tag v1.0.0

# Загрузи тег
git push origin v1.0.0
```

Теперь во вкладке **Releases** появится релиз с .deb файлом!

---

## Если нет Git на Windows

### Установка Git:

1. Скачай: https://git-scm.com/download/win
2. Установи с настройками по умолчанию
3. Перезапусти терминал

### Альтернатива - GitHub Desktop:

1. Скачай: https://desktop.github.com/
2. Установи
3. Войди в аккаунт GitHub
4. Нажми "Add" → "Create New Repository"
5. Выбери папку с проектом
6. Нажми "Publish repository"

Готово! GitHub Desktop автоматически загрузит код и запустит сборку.

---

## Проверка статуса сборки

В репозитории на GitHub появится бейдж:

![Build Status](https://github.com/YOUR_USERNAME/REPO_NAME/workflows/Build%20iOS%20Tweak/badge.svg)

- 🟢 Зеленый = сборка успешна
- 🔴 Красный = ошибка сборки
- 🟡 Желтый = сборка идет

---

## Troubleshooting

**"Permission denied" при git push:**
```bash
# Используй Personal Access Token вместо пароля
# Создай токен: GitHub → Settings → Developer settings → Personal access tokens
# Используй токен вместо пароля при push
```

**"Build failed" в Actions:**
- Открой детали ошибки в Actions
- Обычно это синтаксическая ошибка в Tweak.x
- Исправь и сделай новый push

**Не могу найти .deb:**
- Убедись, что сборка завершилась успешно (зеленая галочка)
- Artifacts появляются только после успешной сборки
- Если сборка красная - смотри логи ошибок

---

## Полезные команды Git

```bash
# Посмотреть статус
git status

# Посмотреть историю
git log

# Отменить изменения
git checkout -- filename

# Создать новую ветку
git checkout -b new-feature

# Переключиться на ветку
git checkout main
```

---

Теперь у тебя автоматическая сборка! Просто меняй код и делай `git push` - GitHub сам всё соберет.
