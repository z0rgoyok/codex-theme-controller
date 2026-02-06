.PHONY: build test run bundle run-app

APP_NAME := CodexThemeController.app
APP_DIR := out/$(APP_NAME)
APP_BIN := $(APP_DIR)/Contents/MacOS/codex-theme-controller
APP_PLIST := $(APP_DIR)/Contents/Info.plist

build:
	swift build

test:
	swift test

run:
	swift run codex-theme-controller

bundle:
	swift build
	rm -rf $(APP_DIR)
	mkdir -p $(APP_DIR)/Contents/MacOS
	cp .build/debug/codex-theme-controller $(APP_BIN)
	cp App/Info.plist $(APP_PLIST)
	chmod +x $(APP_BIN)

run-app: bundle
	open "$(APP_DIR)"
