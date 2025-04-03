# ZPoslib for The Binding of Isaac: Repentance(+)

ZPoslib, or ZPosition Library, is a more robust and complex alternative to 3D positions in The Binding of Isaac.
It features the use of 3D Vectors for 3D position and velocity calculations, and **currently only works with REPENTOGON.**

ZPoslib was created as an alternative to [JumpLib](https://github.com/drpandacat/JumpLib) and [Revelations' proprietary AirMovement library](https://github.com/filloax/revelations-mirror/tree/main/scripts/revelations/common/library/airmovement). It is not a fork or directly based on either of these libraries.

# How does it differ from other libraries?

ZPoslib uses 3D vectors for its calculations. This ensures you are able to do more complicated things with positioning,
as well as velocity.

There is nothing wrong with a smoke and mirrors approach, however, and a general purpose 3D position library might not be for everyone.
For this reason, ZPoslib is a solution for people who wish to have complicated 3D support while still being able to have some amount of compatibility with other mods.

# When should I, or should I not, use this?

There are a few use cases for this library:

- You wish to retain compatibility with other mods.
- You wish to have more control over 3D positioning and velocity.
- You wish to have 3D collisions, and have collisions still work in midair.
- You want to have complicated stage hazards, or a character based on 3D positioning.
- You will have to spend a lot of time dealing with 3D positions.
- You do not necessarily want to implement your own system for 3D positions.

Conversely, here are a few situations where ZPoslib might not be for you:

- You do not wish to bloat your mod with complicated middleware.
- You just want to implement a simple item or effect that makes you jump.
- You do not care about momentum or "accurate" 3D movement.
- You are an inexperienced modder, or just want to get something done quickly.

# How to Use:

## Installation:
Place the library's files into their own folder, ideally within a library or dependency folder.

In ``zpos_init.lua``, change the ``rootFolder`` variable to the path to that folder. e.g. if the path is ``./scripts/lib/zposlib``, it would be ``scripts.lib.zposlib``. 

``include`` the ``zpos_init.lua`` file anywhere in your project. Ideally, you would want to do this publicly, where you'd be able to access it again.

If all has gone well, you should see ``Initializing ZPosLib Version (number)`` in the console.
