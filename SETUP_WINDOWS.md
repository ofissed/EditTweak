# Компиляция iOS твиков на Windows

## Вариант 1: WSL (Рекомендуется)

### Установка WSL:
1. Открой PowerShell от администратора и выполни:
```powershell
wsl --install
```

2. Перезагрузи компьютер

3. После перезагрузки откроется Ubuntu, создай пользователя

### Установка Theos в WSL:

```bash
# Обновляем систему
sudo apt update && sudo apt upgrade -y

# Устанавливаем зависимости
sudo apt install -y git curl build-essential libssl-dev fakeroot perl clang

# Устанавливаем Theos
sudo git clone --recursive https://github.com/theos/theos.git /opt/theos
sudo chown -R $(whoami):$(whoami) /opt/theos

# Добавляем в PATH
echo "export THEOS=/opt/theos" >> ~/.bashrc
echo "export PATH=\$THEOS/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

# Устанавливаем iOS SDK
cd /opt/theos
curl -LO https://github.com/theos/sdks/archive/master.zip
unzip master.zip
mv sdks-master/iPhoneOS*.sdk sdks/
rm -rf sdks-master master.zip
```

### Компиляция твика:

```bash
# Переходим в папку проекта (Windows диски доступны через /mnt/)
cd /mnt/c/Users/ТвоеИмя/путь/к/проекту

# Компилируем
make package

# .deb файл появится в папке packages/
```

### Перенос на iPhone:
1. .deb файл будет в папке `packages/`
2. Перенеси его на iPhone через:
   - iTunes File Sharing
   - Облако (Dropbox, Google Drive)
   - Telegram (отправь себе)
   - USB через iFunBox/3uTools
3. Открой .deb через Filza на iPhone
4. Нажми "Install"
5. Respring

---

## Вариант 2: Docker Desktop

Если WSL не работает, можно использовать Docker:

```bash
# Установи Docker Desktop для Windows
# Затем создай контейнер с Theos

docker run -it --rm -v ${PWD}:/project theos/theos bash
cd /project
make package
```

---

## Вариант 3: Виртуальная машина

1. Установи VirtualBox или VMware
2. Создай виртуалку с Ubuntu
3. Следуй инструкциям для Linux выше

---

## Вариант 4: Компиляция на iPhone (без компьютера)

Если хочешь компилировать прямо на iPhone:

1. Установи NewTerm 2 из Sileo/Cydia
2. Установи Theos на iPhone:

```bash
# В NewTerm выполни:
su
# Пароль: alpine (по умолчанию)

apt-get update
apt-get install -y git perl make

git clone --recursive https://github.com/theos/theos.git /var/theos
echo "export THEOS=/var/theos" >> ~/.bashrc
echo "export PATH=\$THEOS/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

# Компиляция:
cd /путь/к/твоему/проекту
make package
make install
```

---

## Быстрый старт для WSL:

После установки WSL, просто скопируй и выполни:

```bash
# Установка всего за раз
sudo apt update && sudo apt install -y git curl build-essential libssl-dev fakeroot perl clang && \
sudo git clone --recursive https://github.com/theos/theos.git /opt/theos && \
sudo chown -R $(whoami):$(whoami) /opt/theos && \
echo "export THEOS=/opt/theos" >> ~/.bashrc && \
echo "export PATH=\$THEOS/bin:\$PATH" >> ~/.bashrc && \
source ~/.bashrc && \
cd /opt/theos && \
curl -LO https://github.com/theos/sdks/archive/master.zip && \
unzip master.zip && \
mv sdks-master/*.sdk sdks/ && \
rm -rf sdks-master master.zip && \
echo "Theos установлен! Перезапусти терминал."
```

---

## Проблемы и решения:

**"make: command not found"**
```bash
sudo apt install make
```

**"clang: command not found"**
```bash
sudo apt install clang
```

**"No iOS SDK found"**
```bash
cd $THEOS
curl -LO https://github.com/theos/sdks/archive/master.zip
unzip master.zip
mv sdks-master/*.sdk sdks/
```

**Ошибка прав доступа**
```bash
sudo chown -R $(whoami):$(whoami) /opt/theos
```
