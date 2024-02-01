# esx_vehicleshop
esx_vehicleshop rebuild, memakai ox_lib dan ox_target

## Requirements

* Auto mode (everyone can buy vehicles from the dealer)
  * [ox_lib](https://github.com/overextended/ox_lib)
  * [ox_target](https://github.com/overextended/ox_target)

~~Player management (the car dealer job): billing, boss actions and more!~~


## Download & Installation

### Using Git

```
cd resources
git clone https://github.com/rozirwobari/esx_vehicleshop.git [esx]/esx_vehicleshop
```

### Manually

- Download https://github.com/rozirwobari/esx_vehicleshop/archive/refs/tags/V1.0.0.zip
- Put it in the `[esx]` directory

### Installation

- Import `esx_vehicleshop.sql` in your database
- Add this in your `server.cfg`:

```
start esx_vehicleshop
```
- If you want player management you have to set `Config.EnablePlayerManagement` to `true` in `config.lua`

## Legal

### License

esx_vehicleshop - vehicle shop for ESX

Copyright (C) 2015-2023 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
