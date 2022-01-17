# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
### Added
- Lambda definitions can now be failed with custom error messages

## [0.6.1] - 2020-03-21
### Fixed
- The `Keys` definition crashed with an error if the input was not a Hash

## [0.6.0] - 2020-03-21
### Added
- Added include method to Keys Definition that allows to inline other `Keys` Definitions into each other

## [0.5.2] - 2019-06-03
### Fixed
- added missing require for "pathname"

## [0.5.1] - 2019-04-27
### Fixed
- Typo in error debug output

## [0.5.0] - 2019-03-28
### Added
- CoercibleValueObject Definition for better nesting of ValueObjects
- Nilable Definition as shortcut for nil OR some other definition
- Option for Keys Definition to ignore unexpected keys
### Fixed
- Error hash was missing some errors in a few cases
- `ConformResult.error_hash` was empty for Definitions without any `Keys` Definition
### Changed
- And Definition stops processing after the first failure

## [0.4.0] - 2019-03-22
### Added
- Added support for default values to Keys Definition
### Changed
- Errors returned from ConformResult were restructured for better debugging and usage

## [0.3.0] - 2019-02-03
### Added
- Added I18n translation support for errors

## [0.2.0] - 2019-01-13
### Added
- Added built in definitions for common usecases (e.g. string length validation)

## [0.1.0] - 2019-01-12
### Added
- Initial release
