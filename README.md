<img src="https://media.discordapp.net/attachments/868128630683893851/1166400300760961034/iw4cine.png">

# *IW4cine*

### 🎥 A features-rich cinematic mod for Call of Duty®: Modern Warfare® 2 (2009)

<img src="https://img.shields.io/badge/REWRITE%20IN%20PROGRESS-ffc62d?style=flat-square">　<a href="https://github.com/sortileges/iw4cine/releases"><img src="https://img.shields.io/github/v/release/sortileges/iw4cine?label=Latest%20release&style=flat-square&color=ffc62d"></a>　<a href="https://discord.gg/wgRJDJJ"><img src="https://img.shields.io/discord/617736623412740146?label=Join%20us%20on%20Discord&style=flat-square&color=ffc62d"></a>  
<br/><br/>

Designed for video editors to create cinematics shots on **Call of Duty®: Modern Warfare® 2 (2009)**.


This mod creates new dvars combined as player commands. They are all associated to script functions that are triggered with `notifyOnPlayerCommand()`, meaning these functions will all independently stay idle until they get notified to go ahead.

This mod was also designed as a Multiplayer mod only. It will not work in Singleplayer or Spec Ops as is.


<br/><br/>
## Requirements

In order to use the latest version of this mod directly from the repo, you'll need a copy of **Call of Duty®: Modern Warfare® 2 (2009)** with the **IW4x client** installed *(v0.7.3 or higher)*. This is because the mod uses GSC builtins and other features from IW4x.

Older releases of the mod *(#304 and prior)* should work on any IW4 client, shall you be using something else. Injecting these old releases into the Steam version of the game is not recommended and can cause game bans.


<br/><br/>
## Installation

Simply download the mod through [this link](https://github.com/sortileges/iw4cine/releases/latest). Scroll down and click on "Source code (zip)" to download the archive.

<img src="https://i.gyazo.com/76f56263d5f84a2490384a8c2850e0c6.png" alt="screenshot" height="265px" align="right"/>

Once the mod downloaded, open the ZIP file and drag the "Cinematic Mod" folder into your `MW2/mods` folder. If the `mods` folder doesn't exist, create it. (*You can also rename the mod if you'd like.*)

<br/>

```text
X:/
└── .../
    └── IW4x/
        └── iw4x.exe
        └── mods/
            └── Cinematic Mod
```

Then, open your game, and click on the "Mods" tab; "Cinematic Mod" should appear in the list. Click on it once and then click on "Launch" to restart your game with the mod on.

You can also create a shortcut of your client's executable and add the following parameter to the target line : `+set fs_game "mods/Cinematic Mod"`. This will automatically launch the mod when you open the game.

<br/><br/>
## How to use

The repository contains a HTML file that explains every command from the [latest release](https://github.com/sortileges/iw4cine/releases/latest) in details. The HTML file will open a new browser tab when you click on it. Otherwise, you can find it online via **[sortileges.github.io/iw4cine/help](https://sortileges.github.io/iw4cine/help)**.

**It is not up-to-date with what's in the master branch,** although everything should still work as intended. Just don't be surprised if something is missing or not working as expected!

Once the mod's rewrite is complete, the HTML file will be updated accordingly. The new version will be tagged as #400 for its initial release. Current version is #304.

<br/><br/>
## Join us on Discord

We have a Discord server related to the mod, where you can get help and resources, share your work, or just hang out. **[Everyone's welcome!](https://discord.gg/wgRJDJJ)**
