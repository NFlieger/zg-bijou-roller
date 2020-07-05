ZG Bijou Roller
--------------------------------------

This addon rolls NEED, GREED or PASS on bijous and coins dropping in Zul'Gurub.

The default behaviour for both bijous and coins is GREED.
You can change these behaviours using CLI commands as well as using the GUI in Interface Options (or open it via `/zgroll`).


For more info an the CLI commands type `/zgroll help` or read the info below.

To roll differently on bijous (and by default coins), type one of the following:

* `/zgroll need`
* `/zgroll greed`
* `/zgroll pass`

Multiple inputs are allowed. `/zgroll need`, `/zgroll bijou need`, `/zgroll bj need` are all doing the same thing.

The roll behaviour for coins is locked to the behaviour for bijous. This can be changed by typing one of the following:

* `/bijouroll coin need`
* `/bijouroll coin greed`
* `/bijouroll coin pass`

Just like bijou can be abbreviated with bj, coin can be abbreviated with c, such as `/zgroll c need`.
To lock the rolls for coins to bijous again, type `/zgroll coin lock`.