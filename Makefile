APP = Keeper.app

.PHONY: app icon test clean

app:
	swift build -c release
	rm -rf $(APP)
	mkdir -p $(APP)/Contents/MacOS $(APP)/Contents/Resources
	cp .build/release/Keeper $(APP)/Contents/MacOS/Keeper
	cp Resources/Info.plist $(APP)/Contents/Info.plist
	cp Resources/AppIcon.icns $(APP)/Contents/Resources/AppIcon.icns
	codesign --force --sign - $(APP)

icon:
	swift Resources/make-icon.swift Resources

test:
	swift test

clean:
	rm -rf .build $(APP)
