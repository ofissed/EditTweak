TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Telegram

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TelegramEditAnyMessage

TelegramEditAnyMessage_FILES = Tweak.x
TelegramEditAnyMessage_CFLAGS = -fobjc-arc
TelegramEditAnyMessage_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
