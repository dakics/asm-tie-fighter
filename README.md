

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 Tie Fighter
 Srdjan Dakic
 January 1997
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


> [POUET users:][pouet]

> - _"First 256B game I have even played."_

> - _"playable! beep beep!"_

> - _"cool game. playable with dosbox when you lower cpu cycles."_


Story
-----
Aliens are attacking.
Kill 'em all.
Save Earth.


Instructions
------------
As with any other MS-DOS application, on modern OS you need to run it inside [DOSBox]. Download TIE.COM and copy it to the DOSBox-mounted folder.

Tweak CPU speed with **CTRL-11** and **CTRL-12** until it is playable.

  - **LEFT** and **RIGHT SHIFT** - move player
  - **ALT** - fire rocket

If you have sound on, you'll be blasted by the roar of the player rocket launch. There is even a brief explosion if you get killed!

Watch out for invisible alien ships! Search for an air-raid shelter if action gets too wild.

![alt tag](https://raw.github.com/dakics/asm-tie-fighter/master/tie-0.png)


Nerd stuff
----------

  - Game uses undocumented "wait retrace" in one of the [BIOS routines][ax1003] for accurate timing (as much as possible) and to prevent screen tearing.

  - If you slow CPU too much, you will easily figure out how zig-zag alien movement is implemented.
  
  - Sound FX is just random garbage (missile Y position) sent to the speaker port.
  
  
Bug (feature) list
------------------

  - In the upper-left corner missile and bomb appears (whenever there is no player missile), aka "the minefield".

  - Player can go out of the screen and shoot from there, so there is even a "cheat mode" !
  
  - Every time player shoots, "invisible alien ship" drops bomb (undefined SI value).
  
  - Upper-left alien is getting killed in "the minefield", due to shape of the formation this is not obvious.
  
  - Bombs don't appear always exactly below alien.  
  
  
Trivia
------

  - Coded January 2-8 1997.
  
  - Won '256 bytes' compo at YALP '97 held in Belgrade, RS. Check the official report in the TXT file.
  
  - Norton Disk Doctor restored source code after sudden blackout. 1990s were tough.
  
  - Tnx: Bambino, Branko, Glide (RIP), Imperator, Kisa, Darko, Neutron, Skokovic, Tut, Pop, Lemi, Andrej and Zorana.
  

Screenshots
-----------

![alt tag](https://raw.github.com/dakics/asm-tie-fighter/master/tie-1.png)

![alt tag](https://raw.github.com/dakics/asm-tie-fighter/master/tie-2.png)

![alt tag](https://raw.github.com/dakics/asm-tie-fighter/master/tie-3.png)


^^^ BOOM. GAME OVER.
--------------------

[dosbox]: http://www.dosbox.com
[ax1003]: http://www.ousob.com/ng/asm/ng74cc7.php
[pouet]: http://www.pouet.net/prod.php?which=26896