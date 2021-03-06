Ob-workbar
=========

A light workspace indicator bar for Openbox [by Tommy Teasdale]

  - Place the bar on any side of the screen
  - Seperate color for either the bar, inactive workspace and active workspace
  - Automatically adjust to the actual number of workspace
  - Support tranparency
  - Can work on any window manager

Requires Takao font family:

 - For Debian-based Linux, you can install it through this command:
```sudo apt-get install fonts-takao```

Installation
--------------

```$ cd ~/.conky```

```$ git clone https://github.com/Youmy001/ob-workbar.git ob-workbar```

```$ cd ob-workbar```

Execution
------------

```$ conky -c conky.conf```

If you are running another conky config, copy the lua script into the same folder 
as your config, make this config fit your screen resolution and add the following into it:

```lua_load ob-workbar.lua```

```lua_draw_hook_post workbar_main```

Version
------------

  13.06.01		Fixing positioning issues and better integration of the setting table
  
  13.05.31		Working setting table
  
  13.05.30		Original release

License
-

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
	
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


  [by Tommy Teasdale]: http://http://youmy001.deviantart.com/
  
