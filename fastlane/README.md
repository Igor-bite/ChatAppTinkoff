fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### build_for_testing
```
fastlane build_for_testing
```
Build for testing
### run_tests_from_build
```
fastlane run_tests_from_build
```
Run tests
### build_and_test
```
fastlane build_and_test
```
Build and test
### notify_discord_success
```
fastlane notify_discord_success
```
Notify discord via webhook
### notify_discord_error
```
fastlane notify_discord_error
```
Notify discord with error

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
