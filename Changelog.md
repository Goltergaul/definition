# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [1.1.2] - 2024-08-22
### Fixed
- Fixed "TypeError: no _dump_data is defined for class Proc" error that ocurred when a definition model inherits from another model that uses lambda based definitions

## [1.1.1] - 2024-05-21
### Fixed
- Fixed Definition::Model inheritance

## [1.1.0] - 2023-11-22
### Changes
- Improved performance

## [1.0.0] - 2023-02-14
### Removed
- Removed deprecated version of `GreaterThanEqual` definition that had a typo in it (GreaterThenEqual)
- Removed deprecated version of `GreaterThan` definition that had a typo in it (GreaterThen)
- Removed deprecated version of `LessThanEqual` definition that had a typo in it (LessThenEqual)
- Removed deprecated version of `LessThan` definition that had a typo in it (LessThen)

## [0.8.1] - 2022-10-05
### Fixed
- Definition::Model#eql? returns true when comparing two models with the same content

## [0.8.0] - 2022-10-05
### Added
- A Definition::Initializer mixin that can be used to validate keyword arguments of a class constructor

### Changes
- Include more information in the internal non-translated error messages. E.g. the max size of a LessThenEqual definition
- Renamed GreaterThen, GreaterThenEqual, LessThen and LessThenEqual to fix typo (Then VS Than) Backwards compatibility is ensured

### Breaking changes
- The Definition::ValueObject was removed and replaced by Definition:Model which has a nicer DSL and only works with hash data structures. See [upgrade notes](./UpgradeNotes.md)

## [0.7.1] - 2022-03-04
### Fixed
- Float coercion: check for nil before coercion

## [0.7.0] - 2022-02-25
### Added
- Lambda definitions can now be failed with custom error messages
- Compatibility with Ruby 3.0
### Fixed
- In some cases errors from nested `Keys` definitions inside `Or` definitions got lost when listing the validation errors via the `error_hash` method on the conform result object.
### Changed
- When no sub-definition of an `Or` conforms, then only the errors of the last definition of the `Or` are collected. Previously the errors of all sub-definitions were collected.
- Translated error messages have been improved to be more suitable to be used as end user error messages

## [0.6.1] - 2021-12-14
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
