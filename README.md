

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 Tie Fighter
 Srdjan Dakic
 January 1997

 WINNER in "256 bytes" compo at YALP '97  (Belgrade, RS)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



Instructions
------------
As with any other MS-DOS application, on modern OS you need to run it inside [DOSBox].

Tweak CPU speed with **CTRL-11** and **CTRL-12** until it is playable.

  - **LEFT / RIGHT SHIFT** - move player ship
  - **LEFT ALT** - fire rocket

If you have sound on, you will be blasted by roar of the player rocket launch. There is even a brief explosion if you get killed!

![alt tag](https://raw.github.com/dakics/asm-tie-fighter/master/tie-0.png)


Nerd stuff
----------

  - Game uses undocumented "wait retrace" in one of the [BIOS routines][ax1003] for accurate timing (as much as possible) and to prevent screen tearing.

  - If you slow CPU too much, you will easily figure out how zig-zag alien movement is implemented.


Screenshots
-----------

![alt tag](https://raw.github.com/dakics/asm-tie-fighter/master/tie-1.png)

![alt tag](https://raw.github.com/dakics/asm-tie-fighter/master/tie-2.png)

![alt tag](https://raw.github.com/dakics/asm-tie-fighter/master/tie-3.png)


[dosbox]: http://www.dosbox.com
[ax1003]: http://www.ousob.com/ng/asm/ng74cc7.php