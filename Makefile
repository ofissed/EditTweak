TARGET := iphone:clang:12.4:12.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TelegramEditAnyMessage

TelegramEditAnyMessage_FILES = Tweak.xm
TelegramEditAnyMessage_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk