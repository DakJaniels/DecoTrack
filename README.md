# DecoTrack

[![Version](https://img.shields.io/badge/version-2.6-blue.svg)](change.log)
[![ESO](https://img.shields.io/badge/ESO-Update%2046-green.svg)](change.log)
[![Multi-Server](https://img.shields.io/badge/Multi--Server-Supported-brightgreen.svg)](change.log)

> Automatically maintain a database of your furniture items across all homes, characters, banks, storage coffers, and storage chests in The Elder Scrolls Online.

![DecoTrack Example](https://github.com/DakJaniels/DecoTrack/raw/26177ef79e852096e818702e66b570ffd451df20/example.jpg)
*Example of DecoTrack's furniture tracking interface*

## Features

- 🔄 **Automatic Tracking**: Automatically catalogs furniture as you:
  - Visit your bank
  - Enter your homes
  - Access storage chests and coffers
  - Log in with characters
  - Acquire new furniture
  - Move existing furniture

- 🔍 **Seamless Integration**: Works with:
  - Housing Hub
  - Essential Housing Tools

- 📊 **Comprehensive Search**: Find your furniture items by:
  - Item name (full or partial)
  - Item category
  - Character name
  - House name
  - Storage location
  - Bank contents

## Installation

1. Download the latest release
2. Extract to your ESO AddOns directory
3. Enable the addon in-game
4. That's it! DecoTrack will automatically start tracking your furniture

## Usage

### Housing Hub Interface

Open the Housing Hub through any of these methods:
- Type `/hub` in chat
- Click the "Home" icon in the game's top menu bar
- (EHT) Mouse over the "EHT" button and click "Housing Hub"
- (Housing Hub) Click the Hub Widget while in a house

Then:
1. Click the "Furniture" tab
2. Use the search field at the bottom to find items
3. Browse your furniture across all locations

### Chat Commands

Use the `/deco` command with various search phrases:

```lua
/deco search_phrase
```

#### Examples:

| Command | Searches for |
|---------|-------------|
| `/deco daedric base` or `/deco base` | Daedric base items |
| `/deco lighting` or `/deco lig` | Lighting items |
| `/deco grand topal hideaway` or `/deco topal` | Items in Grand Topal Hideaway |
| `/deco bank` | Items in bank |
| `/deco storage coffer` | Items in storage coffers |
| `/deco Suzy the Sorc` or `/deco Suzy` | Items on character "Suzy the Sorc" |

### Auto-Update

Don't want to visit every house manually? Use:

```lua
/deco update
```

This will automatically visit all your houses and update the database. Perfect time for a coffee break! ☕

## Search Results

Results are organized by:
- Item category
- Quantity per location
- Location type (house, coffer, chest, character, bank)

## Contributing

Found a bug or have a suggestion? Please open an issue or submit a pull request.

---

*Made with ❤️ for ESO housing enthusiasts*