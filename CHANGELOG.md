#### v2.0.5:

* Interface version for patch 1.13.5 fixed.

#### v2.0.4:

* Interface version number in toc file fixed.
* Other minor fixes and changes.

#### v2.0.0:

* GUI added for easier roll changes.
* Option added to persist settings after relog / reloadui.
* To open the GUI use either /zgroll or head into "ESC" -> "Interface Options" -> "AddOns" -> "ZG Bijou Roller".
* All previous CLI commands are still working as before.
* Refactoring for [AQ Idol Roller](https://www.curseforge.com/wow/addons/aq-idol-roller) done.

#### v1.1.1:

Seperate rolls for coins and bijous added:

* the old commands (/bijouroll [need|greed|pass]) still work the same as before
* by default the roll behaviour for coins is locked to the behaviour for bijous
* to unlock the coin rolls, use /zgroll [c|coin] [need|greed|pass]
* to lock the coins again, use /zgroll [c|coin] lock

Command line parameters (like need, greed and pass) are no longer case sensitive.

Versioning in ZGBijouRoller.toc fixed.