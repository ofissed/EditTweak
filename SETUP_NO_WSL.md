# Компиляция iOS твиков на Windows БЕЗ WSL

## Вариант 1: Компиляция прямо на iPhone (САМЫЙ ПРОСТОЙ)

Не нужен компьютер вообще! Всё делается на телефоне.

### Что нужно:
- Джейлбрейкнутый iPhone
- NewTerm 2 (терминал для iOS) - установи из Sileo/Cydia
- Filza File Manager

### Установка Theos на iPhone:

1. Открой NewTerm 2
2. Выполни команды:

```bash
# Получаем root права
su
# Пароль: alpine (если не менял)

# Обновляем пакеты
apt-get update

# Устанавливаем зависимости
apt-get install -y git perl make ldid

# Клонируем Theos
git clone --recursive https://github.com/theos/theos.git /var/theos

# Настраиваем переменные
echo "export THEOS=/var/theos" >> ~/.bashrc
echo "export PATH=\$THEOS/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

# Выходим из root
exit
```

### Создание и компиляция твика:

```bash
# Создаем папку для проекта
mkdir ~/MyTweak
cd ~/MyTweak

# Копируем файлы проекта сюда через Filza
# Или создаем прямо в NewTerm

# Компилируем
make package

# Устанавливаем
make install

# Перезапускаем SpringBoard
killall -9 SpringBoard
```

---

## Вариант 2: MSYS2 (Linux-окружение для Windows)

### Установка:

1. Скачай MSYS2: https://www.msys2.org/
2. Установи его
3. Открой "MSYS2 MSYS" из меню Пуск
4. Выполни:

```bash
# Обновляем систему
pacman -Syu

# Устанавливаем зависимости
pacman -S git make perl gcc clang

# Клонируем Theos
git clone --recursive https://github.com/theos/theos.git /opt/theos

# Настраиваем
echo "export THEOS=/opt/theos" >> ~/.bashrc
echo "export PATH=\$THEOS/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

# Скачиваем iOS SDK
cd /opt/theos
curl -LO https://github.com/theos/sdks/archive/master.zip
unzip master.zip
mv sdks-master/*.sdk sdks/
rm -rf sdks-master master.zip
```

### Компиляция:
```bash
cd /c/Users/ТвоеИмя/путь/к/проекту
make package
```

---

## Вариант 3: Cygwin

Похож на MSYS2, но старее:

1. Скачай Cygwin: https://www.cygwin.com/
2. При установке выбери пакеты: git, make, perl, gcc, clang
3. Дальше как в MSYS2

---

## Вариант 4: Онлайн-компиляция (iOS App Store)

Есть приложения для iOS, которые могут компилировать твики:

### iSH Shell (из App Store):
- Это Linux эмулятор для iOS
- Можно установить Theos прямо в нем
- Работает медленнее, но не требует джейлбрейк для установки самого iSH

```bash
# В iSH:
apk add git make perl clang
git clone https://github.com/theos/theos.git ~/theos
export THEOS=~/theos
```

---

## Вариант 5: Облачная компиляция

### GitHub Actions (бесплатно):

Создай файл `.github/workflows/build.yml`:

```yaml
name: Build Tweak

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Theos
      run: |
        sudo git clone --recursive https://github.com/theos/theos.git /opt/theos
        sudo chown -R $(whoami):$(whoami) /opt/theos
        echo "export THEOS=/opt/theos" >> ~/.bashrc
        
    - name: Download SDK
      run: |
        cd /opt/theos
        curl -LO https://github.com/theos/sdks/archive/master.zip
        unzip master.zip
        mv sdks-master/*.sdk sdks/
        
    - name: Build
      run: |
        export THEOS=/opt/theos
        make package
        
    - name: Upload DEB
      uses: actions/upload-artifact@v2
      with:
        name: tweak-package
        path: packages/*.deb
```

Теперь при каждом push в GitHub автоматически скомпилируется .deb!

---

## МОЯ РЕКОМЕНДАЦИЯ:

**Для тебя лучше всего - компиляция на iPhone:**

✅ Не нужен компьютер  
✅ Всё на одном устройстве  
✅ Быстрая установка и тестирование  
✅ Не нужно переносить файлы  

**Пошагово:**

1. Установи NewTerm 2 из Sileo
2. Открой NewTerm
3. Выполни:
```bash
su
# Пароль: alpine
apt-get update && apt-get install -y git perl make ldid && git clone --recursive https://github.com/theos/theos.git /var/theos && echo "export THEOS=/var/theos" >> ~/.bashrc && source ~/.bashrc && exit
```

4. Создай папку для твика в Filza
5. Скопируй туда файлы Tweak.x, Makefile, control, .plist
6. В NewTerm:
```bash
cd /var/mobile/путь/к/твоему/проекту
make package
make install
killall -9 SpringBoard
```

Готово! Твик установлен.

---

## Если всё равно хочешь на Windows без WSL:

Используй **MSYS2** - это самый простой вариант после WSL.

Какой вариант попробуешь?
