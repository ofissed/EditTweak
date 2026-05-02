TARGET := iphone:clang:14.5:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TelegramEditAnyMessage

TelegramEditAnyMessage_FILES = Tweak.x
TelegramEditAnyMessage_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
