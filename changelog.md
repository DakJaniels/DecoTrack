# Changelog

All notable changes to DecoTrack will be documented in this file.

## [2.7.3] - 2025-11-15
### Fix
- Default value was not being initialized for the House Update Delay.

## [2.7.2] - 2025-07-31
### Added
- Configurable house update delay setting for custom recall animations
- Users can now adjust the timing between house visits during automatic updates
### Changed
- House update delay is now configurable via settings panel (1-30 seconds, 0.5 second steps)
- Default delay remains 1.5 second.

## [2.6] - 2025-05-31
### Added
- Multi-Server support
- Support for the Furniture Vault

### Changed
- API update for Update 46
- New Dependencies, LibChatMessage
- Reset SavedVariables (requires visiting houses again)

## [2.5] - 2023-03-11
### Changed
- API update

## [2.4] - 2021-06-05
### Changed
- API update

## [2.3] - 2021-03-07
### Changed
- API update

## [2.2] - 2021-02-13
### Fixed
- Tooltips now correctly display grand total for furnishings in multiple homes

## [2.1] - 2021-02-09
### Fixed
- Resolved conflicts with chat-related add-ons
### Changed
- Reformatted `/deco` command output

## [2.0] - 2021-02-07
### Changed
- Improved integration with Essential Housing Tools and Housing Hub

## [1.9] - 2020-12-01
### Fixed
- DecoTrack tab now works properly in Essential Housing Tools' Housing Hub

## [1.8] - 2020-11-29
### Added
- New Addon Settings panel with features:
  - Auto Update process for visiting all homes
  - Database reset option
### Changed
- Now requires LibAddonMenu2

## [1.7.6] - 2020-07-26
### Changed
- API update

## [1.7.5] - 2020-05-26
### Added
- New developer: Architectura
- Tracking of bound vs. unbound items (Crown, achievement, etc.)
- Updated EHT integration to display bound/unbound counts
### Changed
- Added `/deco update` command for automatic home data updates

## [1.7.3] - 2020-03-01
### Changed
- API update

## [1.7.2] - 2019-10-24
### Fixed
- Lua error when previewing recipe items

## [1.7.1] - 2019-10-24
### Added
- Item inventory data to additional item tooltips

## [1.7.0] - 2019-10-24
### Added
- Item inventory data to most item tooltips

## [1.6.8] - 2019-10-22
### Changed
- Verified support for Update 24, API 29
- Adjusted `/deco totals` output formatting

## [1.6.7] - 2019-07-28
### Changed
- Verified support for Update 23, API 28

## [1.6.6] - 2019-05-13
### Added
- Enhanced furniture search with exclusion support using "-" prefix
  - Example: `replica -dream` finds "Replica Black Soul Gem" but not "Replica Dreamshard"
  - Example: `estate -surreal` finds "Serenity Falls Estate" but not "Coldharbour Surreal Estate"

## [1.6.5] - 2019-03-15
### Added
- New visual UI in Essential Housing Tools' Housing Hub
- Direct search functionality from EHT interface
### Changed
- Updated `/deco update` to auto-reload UI after completion

## [1.6.4] - 2019-02-19
### Changed
- Updated for Wrathstone DLC

## [1.6.3] - 2018-12-31
### Changed
- Improved `/deco update` performance
### Fixed
- Bank totals sync issue for ESO Plus subscribers

## [1.6.2] - 2018-10-22
### Changed
- API version increment

## [1.6.0] - 2018-09-01
### Added
- Search UI in Essential Housing Tools
### Fixed
- Eliminated unnecessary furniture database updates after moving items

## [1.5.0] - 2018-08-30
### Added
- EHT integration for inventory data in HUD display

## [1.4.0] - 2018-08-27
### Added
- Character inventory furniture tracking
- Automatic updates on character login

## [1.3.1] - 2018-08-23
### Changed
- Further reduced SavedVariables file size
### Fixed
- Storage coffer/chest content saving
- Inaccurate quantity reporting for storage and bank

## [1.3.0] - 2018-08-22
### Added
- Bank furniture tracking
- Storage chest/coffer tracking
- `/deco update` command for automatic house visits

## [1.2.0] - 2018-08-21
### Changed
- Reduced SavedVariables file size for better performance

## [1.1.0] - 2018-08-20
### Added
- House name search functionality

## [1.0.0] - 2018-08-17
### Added
- Initial release