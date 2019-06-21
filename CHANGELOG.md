# Changelog
## [2.0.17]
### Changed
- Set light mode on Yahoo Finance screens

## [2.0.16]
### Changed
- Fix decimal numbers separator issue for european region
- Fix overlapping text in transactions screen

## [2.0.9]
### Added
- TradeItSDK.debug option to print logs to console
- Fractional shares support to TradeIt screens

## [2.0.8]
### Added
- Yahoo crypto ticket
- Add streaming data protocol to add streaming market data to the trading ticket
- Support fractional shares on equity ticket
- Adds learn more button to Yahoo broker selection

### Changed
- Updated PromiseKit to ~> 6.0

## [2.0.7]
### Changed
- Added @objc annotation to public interface

## [1.1.43]
### Changed
- Fix crashing when account is unlinked
- Update TradeItPosition: added new fields currency, exchange, todayGainLossAbsolute, totalGainLossAbsolute. Marked todayGainLossDollar and totalGainLossDollar as deprecated.

## [1.1.42]
### Changed
- Update relinking method

## [1.1.41]
### Added
- Add missing notification constants for row selection instrumentation

### Changed

### Removed

## [1.1.40]
### Added
- Instrument Yahoo broker selection

### Changed

### Removed

## [1.1.39]
### Added
- Transactions screen
- Flag to handle Fidelity migration

### Changed
- Improved trading ticket, using order capabilities
- Fixed content casing consistency

### Removed

## [1.1.38]
### Added
- Order screens

### Changed
- Improved portfolio capitalization

### Removed

## [1.1.37]
### Added
- Transactions screens

### Changed
- Change `marginType` field to new API format `userCanDisableMargin` and `userDisabledMargin` 

### Removed
