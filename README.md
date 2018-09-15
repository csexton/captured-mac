<img align="right" src="/Captured/Assets.xcassets/AppIcon.appiconset/icon_128x128.png?raw=true" />

# Captured

Screen Capture Sharing for Mac

## Building

Captured uses [SwiftLint](https://github.com/realm/SwiftLint) as part of the build step, so you need to have that installed. If you are using homebrew:

```
brew install swiftlint
```

## Build a pre-release

To create a pre-release use the `Package` target, which will build and tar and gzip everything. This `.tar.gz` file can then be shared with beta testers. There is a `make upload` task that can be run from the command line that will `scp` the file to the captured web server.

## Build for the App Store

TODO: Describe this one.

## License

This repo is MIT License unless otherwise noted. See [LICENSE](LICENSE) for details.
