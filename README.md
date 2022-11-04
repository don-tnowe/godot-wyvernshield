# Wyvernshield

A framework for combat systems. It aims to provide generic building blocks to create games where the player (or their enemies!) can have their stats, or even combat behaviours, change dynamically.

All you need:

- A **Combat Actor**, the CPU of the system.
- A **StatusCarrier** for the actor if they can be affected by **StatusEffects**.
- A **Hurtbox** for the actor if they take damage from **DamageArea**s.
- A **Weapon** for the actor if their combat moves create **DamageArea**s, or even a **HeroWeapon** to make it listen to the player!

# Package contents

    Or, "what do i need from here?!?!"

- [addons/wyvernshield_RPG](./addons/wyvernshield_RPG/) contains all classes required for this system to function. As of now, the plugin does not need to be activated.

- [assets/wyvernshield](./assets/wyvernshield/) is a base library with some resource files ready to use. It is recommended to study how these work first time, but some (*or all, if you dare*) contents can be cut.
    - [trigger_library.tres](./assets/wyvernshield/trigger_library.tres) contains commonly used triggers and their results' parameters. **Very Highly recommended to keep.**
    - [trigger_reactions](./assets/wyvernshield/trigger_reactions/) contains lots of common reactions. **Highly recommended to keep.**
    - [scenes](./assets/wyvernshield/scenes/) puts things together. **Keep if you want to try things out or need some pre-made actors**. Contains a test scene, as well as prefabs for a hero and a stationary enemy that slows on hit.
    - [stat_sheets](./assets/wyvernshield/stat_sheets/) contains default stats for actors in the scenes folder. **Keep only if you use the pre-made actors.**
    - [combat_moves](./assets/wyvernshield/combat_moves/) contains basic combat moves: a melee attack, a triple shot, a fire bomb and a health recovery boost. **Used by the pre-made player actor, can give a starting point for your own moves.**
    - [status_effects](./assets/wyvernshield/status_effects/) contains a Defense Reduction, a Move Speed Reduction and a Damage Over Time burn effect. **Used by pre-made actors. Are generic enough to be kept for most games. Don't forget to Make Unique if you use them, to keep extra vars.**

- [assets/graphics](./assets/graphics/) has the font used by damage numbers and the pre-made player actor HUD. License included. Folder also contains 2 actor sprites and a tiling texture.

# The Base Concepts

## ![Trigger Reactions](README/title_trigger.png)

    When a thing happens, the reactions react to it.

Held inside a **TriggerSheet** of a **CombatActor**, which maps triggers (*things that happen: actor attacks, actor takes damage...*) to reactions.

Reactions of one trigger are executed in order of Priority (*highest first*) and can change the trigger's outcome.

Create a Trigger Results array for a Trigger Sheet using fuctions generated inside **TriggerStatic**, then pass into the actor's `triggers.apply_reactions()`. Then do whatever with the result!

The **TriggerSheet** has functions to add or remove reactions at runtime.

To create your own **TriggerReaction**, you'll need to pass it a script extending **TriggerReactionInstance** that has a function you'll want to call.

Extra Vars can be set to create the instance with different parameters - make it use the instance's `extra_vars` array. This is how the Status Effect on Hit reaction defines which effect gets applied and what its duration and strength is!

Manage trigger names and properties in your **TriggerLibrary** instance, located in [assets/wyvernshield/trigger_library.tres](assets/wyvernshield/trigger_library.tres). **Edit in-engine, then click Force Update.**

## ![Stat Sheets](README/title_stat.png)

    Holds stats and statsheets, which hold more stats and statsheets.

Maps string names to numeric values. The values of each stat are added up from all sheets.

- `stat_name + 10` or `stat_name = 10`: add to the stat total.
- `stat_name - 10`: subtract from the stat total.
- `stat_name x 10` or `stat_name * 10`: multiply the stat total. (*stacks multiplicatively: x2 and x3 make x6*)

The **StatSheet** has functions to add or remove sub-sheets at runtime.

All stat contributions of a sheet can be multiplied. Don't forget to duplicate the instance!

## ![Status Effects](README/title_status.png)

    Adds statsheets and reactions. Removes them after some time.

Are applied to **CombatActor**s, which pass them to their **StatusCarrier**s to keep and process.

Effects have Potency, which multiplies an effect's stat alterations.

## ![Combat Moves](README/title_moves.png)

    The meat of the battles. Do a variety of stuff - on command.

Main purpose is to exchange hits between actors. You can use them directly on other actors with `use_directly()`, but if attacks must be spawned in the world, must be used by **Weapon**s with `use_power()` and **HeroWeapon**s with player input.

They can spawn scenes, of which most should be **DamageArea**s that hit **Hurtbox**es (*not **CombatActor**s themselves!*). The Base Power defines damage dealt. Optionally, moves cost the actor various types of energy, or even health!

They can also change stats on use and on hit. If you give it:

    2s:
    health_regen * 8.0

you'll increase `health_regen` by 8 times, for 2 seconds.

# "But wait!!! The feature I need is not here!!!!!!"

Yeah. This is just a framework - **you can use all of this to help create your game, but it's not an "any game creator" addon.** The purpose is not to cover all mechanics that can exist in RPGs. But it can still be used to simplify some mechanics:

- **Experience for levels?** Create an "Experience on NPC defeated" reaction that adds XP to the player's actor. You could even create a Trigger and apply it to any Experience gain.

- **Skill trees?** Changing a HeroWeapon's moves and an Actor's stats is possible, but ways to unlock them are out of scope: Wyvernshield only covers the processes within combat, not connected systems.

- **Skill experience training?** Create a trigger reaction that reacts to usage of the skill - give Experience in response. The skill level can be a stat!

- **Attribute requirements for moves?** Give the move a reaction to the "Combat Move Check Cost" trigger that checks the user's stats - if not enough, `result[CAN_CAST] = false`.

- **Inventory system?** Out of scope, Wyvernshield only covers combat.

- **Equipment?** Create stat sheets at runtime, and add as subsheets to the main sheet, or its subsheet specifically for equipment. Reactions can be added too!

- **Attribute requirements for equipment???** Stats.

- **Turn-based combat?** Moves can be used directly on target actors.

- **Move Cooldowns?** Use status effects/temporary stat changes that say "this move can't be used"! Or better, extend the Weapon and CombatMove classes to add a cooldown tracker!

- **Enemy AI?** Varies game to game, too many to include.

- **Minion/Building moves?** Moves can spawn scenes with an Actor component, doesn't need to be a Damage Area!

- **Mounts? Transformations?** You could swap out the stat sheets and combat moves of the actor. Handle the visual change yourself though.

#

Made by Don Tnowe in 2022.

https://redbladegames.netlify.app

https://twitter.com/don_tnowe

Copying and Modiication is allowed in accordance to the MIT license, full text is included.
