/*
 *      IW4cine
 *      Default settings - "The poor man's GSH"
 */

load_defaults()
{
    level.COMMAND_PREFIX            = "mvm";    // "text" - Prefix of the commands. Can be blank ("") to disable globally. You can disable it per-command in the scripts/commands.gsc file
    level.COMMAND_COLOR             = "^3";     // "^#" - q3 color code for the commands' descriptions and killfeed messages. Can be blank ("") to disable globally.

    level.MATCH_UNLIMITED_TIME      = true;     // [true/false] - Unlimited time
    level.MATCH_UNLIMITED_SCORE     = true;     // [true/false] - Unlimited score
    level.MATCH_KILL_SCORE          = 100;      // integer - The default score per kill
    level.MATCH_KILL_BONUS          = false;    // [true/false] - Whether or not to give bonuses (headshot, longshot, etc.) for kills

    level.BOT_KILLCAMTIME           = 3;        // integer - Total time of the killcam in seconds, to control respawn delay (0 = instant respawn, -1 = reset killcam behavior)
    level.BOT_MOVE                  = false;    // [true/false] - Changes all testclients dvars (except _watchKillcam) to make them static
    level.BOT_WEAPHOLD              = true;     // [true/false] - Makes bots hold their weapons on death by default
    level.BOT_LATERAGDOLL           = true;     // [true/false] - Bot corpses will ragdoll only when the death animation has almost fully ended
    level.BOT_SPAWNCLEAR            = false;    // [true/false] - Clears ALL corpses whenever a bot spawns
    level.BOT_AUTOCLEAR             = 5;        // float - Time in seconds before a corpse deletes itself. 0 to disable.

    level.PLAYER_MOVEMENT           = true;     // [true/false] - Turn fall damage, stamina and jump slowdown on or off
    level.PLAYER_AMMO               = true;     // [true/false] - Gives you ammo and equipment upon reloading/using 
    
    level.VISUAL_LOD                = true;     // [true/false] - Increase LOD distances. MIGHT MAKE YOUR WEAPON FLICKER ON SOME MAPS!!!!
    level.VISUAL_HUD                = false;    // [true/false] - When false, hides the weaponbar/scorebar/minimap; Uses the scr_gameEnded dvar.

    level.ACTOR_NAME_PREFIX         = "actor";  // "text" - Actors' default name (e.g. "Guy" will result in "Guy1", "Guy2", etc)
    level.ACTOR_SHOW_NAMES          = false;     // [true/false] - Toggles names being displayed when looking at an actor
    level.ACTOR_SHOW_KILLFEED       = false;     // [true/false] - Creates fake killfeed when killing an actor. Only works with IW4x versions that has "emojis" support.
}