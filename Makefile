CONFIGURATION_BUILD_DIR=./Build

all : clean package

package :
	xcodebuild -project Captured.xcodeproj -target Package -configuration Debug build

build :
	xcodebuild -project Captured.xcodeproj -target Captured -configuration Debug build

test :
	xcodebuild -project Captured.xcodeproj -scheme Captured -configuration Debug test

clean :
	@xcodebuild clean
	@rm -rf build

upload :
	scp $(CONFIGURATION_BUILD_DIR)/Debug/Captured-*.tar.gz captured_web@capturedapp.com:capturedapp.com/

