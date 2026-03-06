# ─── YTSettingsButton – Makefile ────────────────────────────────────────────
# Target: dylib da iniettare in IPA (no jailbreak)
# Compilazione: Theos su macOS o via GitHub Actions
# Variabile richiesta: export THEOS=/percorso/a/theos

TARGET          := iphone:clang:16.5:14.0
ARCHS           := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME      := YTSettingsButton

YTSettingsButton_FILES          := Tweak.x
YTSettingsButton_CFLAGS         := -fobjc-arc
YTSettingsButton_FRAMEWORKS     := UIKit Foundation
YTSettingsButton_LIBRARIES      :=

# Bundle ID di YouTube (usato da Theos per il filter plist)
YTSettingsButton_BUNDLE_ID      := com.google.ios.youtube

include $(THEOS_MAKE_PATH)/tweak.mk

# Dopo il build, mostra dove si trova la dylib
after-all::
	@echo ""
	@echo "✅ Build completato."
	@echo "   dylib → $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib"
	@echo "   .deb  → packages/"
	@echo "Per iniettare nell'IPA: usa GitHub Actions (vedi .github/workflows/build.yml)"
