# Wyvernshield

A framework of a combat system. It aims to provide generic building blocks to allow games where the player (or their enemies!) can have their stats, or even combat behaviours, change dynamically.

All you need:

- A **Combat Actor**, the CPU of the system.
- A **StatusCarrier** for the actor if they can be affected by **StatusEffects**.
- A **Hurtbox** for the actor if they take damage from **DamageArea**s.
- A **Weapon** for the actor if they can create **DamageArea**s, or even a **HeroWeapon** to make it listen to the player!

# The Base Concepts

## ![Trigger Reactions](README/title_trigger.png)

    When a thing happens, the reaction reacts to it.

Held inside a **TriggerSheet** of a **CombatActor**, which maps triggers (*things that happen: actor attacks, actor takes damage...*) to reactions.

Reactions of one trigger are executed in order of Priority and can change the trigger's outcome.

To create a **TriggerReaction**, you'll need to pass it a script extending **TriggerReactionInstance** that has a function you'll want to call.

Extra Vars can be set to be call the function with different parameters - make it use the instance's `extra_vars`. This is how the Status Effect on Hit reaction changes an effect's strength!

Manage trigger names and properties in your **TriggerLibrary** instance, located in [assets/wyvernshield/trigger_library.tres](assets/wyvernshield/trigger_library.tres). **Edit in-engine, then click Force Update.**

Create Trigger Results for a Trigger Sheet using fuctions generated inside **TriggerStatic**, then pass into the actor's `triggers.apply_reactions()`. Then do whatever with the result!

The **TriggerSheet** has functions to add or remove reactions at runtime.

## ![Stat Sheets](README/title_stat.png)

    Holds stats and statsheets, which hold more stats and statsheets.

Maps string names to numeric values. The values of each stat are added up from all sheets.

- `stat_name + 10` or `stat_name = 10`: add to the stat total.
- `stat_name - 10`: subtract from the stat total.
- `stat_name x 10` or `stat_name * 10`: multiply the stat total. (*stacks multiplicatively: x2 and x3 make x6*) 

All stat contributions of a sheet can be multiplied. Don't forget to duplicate the instance!

## ![Status Effects](README/title_status.png)

    Add statsheets and reactions. Removes the after some time.

Are applied to **CombatActor**s, which pass them to their **StatusCarrier**s to keep.

Effects have Potency, which multiplies an effect's stat alterations.

## ![Combat Moves](README/title_moves.png)

    The meat of the battles. Do a variety of stuff - on demand.

Main purpose is to exchange hits between actors. If attacks must be spawned in the world, must be used by **Weapon**s and **HeroWeapon**s.

They can spawn scenes, of which most should be **DamageArea**s that hit **Hurtbox**es (*not **CombatActor**s themselves!*). The Base Power defines damage dealt. Optionally, moves cost the actor various types of energy, or even health!

They can also change stats on use and on hit. If you give it:

    2s:
    health_regen * 8.0

you'll increase `health_regen` by 8 times, for 2 seconds.
