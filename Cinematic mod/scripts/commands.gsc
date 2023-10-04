/*
 *      IW4cine
 *      Commands handler
 */

#include scripts\utils;

registerCommands()
{
    level endon( "disconnect" );

    // Misc
    self thread createCommand( "clone",         "Create a clone of yourself",           " ",                            scripts\misc::clone,        false );
    self thread createCommand( "givecamo",      "Give yourself a weapon",               " <weapon_mp> <camo_name>",     scripts\misc::give,         false );
    self thread createCommand( "drop",          "Drop your current weapon",             " ",                            scripts\misc::drop,         false );
    self thread createCommand( "about",         "About the mod",                        " ",                            scripts\misc::about,        false );
    self thread createCommand( "clearbodies",   "Remove all player/bot corpses",        " ",                            scripts\misc::clear_bodies, false );
    self thread createCommand( "viewhands",     "Change your viewmodel",                " <model_name>",                scripts\misc::viewhands,    false );
    self thread createCommand( "eb_explosive",  "Explosion radius on bullet impact",    " <radius>",                    scripts\misc::expl_bullets, false );
    self thread createCommand( "eb_magic",      "Kill bots within defined FOV value",   " <degrees>",                   scripts\misc::magc_bullets, false );

    self thread createCommand( "spawn_model",   "Spawn model at your position",         " <model_name>",                            scripts\misc::spawn_model );
    self thread createCommand( "spawn_fx",      "Spawn FX at your xhair",               " <fx_name>",                               scripts\misc::spawn_fx );
    self thread createCommand( "vision",        "Change vision, reset on death",        " <vision>",                                scripts\misc::visione );
    self thread createCommand( "fog",           "Change ambient fog",                   " <start> <half> <r> <g> <b> <a> <time>",   scripts\misc::fogc );

    // Bots
    self thread createCommand( "bot_spawn",     "Add a bot",                            " <weapon_mp> <axis/allies> <camo_name>",   scripts\bots::add );
    self thread createCommand( "bot_move",      "Move bot to xhair",                    " <bot_name>",                              scripts\bots::move );
    self thread createCommand( "bot_aim",       "Make bot look at closest enemy",       " <bot_name>",                              scripts\bots::aim );
    self thread createCommand( "bot_stare",     "Make bot stare at closest enemy",      " <bot_name>",                              scripts\bots::stare );
    self thread createCommand( "bot_model",     "Swap bot model",                       " <bot_name> <MODEL> <axis/allies>",        scripts\bots::model );
    self thread createCommand( "bot_kill",      "Kill bot",                             " <bot_name> <body/head/cash>",             scripts\bots::kill );
    self thread createCommand( "bot_holdgun",   "Toggle bots holding guns when dying",  " ",                                        scripts\misc::toggle_holding );
    self thread createCommand( "bot_freeze",    "(Un)freeze bots",                      " ",                                        scripts\misc::toggle_freeze );

    // Actors
    self thread createCommand( "actorback",     "Reset all actors to previous state",   " ",                                                        scripts\actors::back, false );
    self thread createCommand( "actor_anim",    "Set actor's main animation",           " <actor_name> <anim_name>",                                scripts\actors::playanim );
    self thread createCommand( "actor_copy",    "Spawn a copy of an existing actor",    " <actor_name>",                                            scripts\actors::copy );
    self thread createCommand( "actor_death",   "Set actor's death animation",          " <actor_name> <anim_name>",                                scripts\actors::deathanim );
    self thread createCommand( "actor_spawn",   "Add an actor",                         " <body_model> <head_model>",                               scripts\actors::add );
    self thread createCommand( "actor_move",    "Move actor to xhair",                  " <actor_name>",                                            scripts\actors::move );
    self thread createCommand( "actor_health",  "Set actor's health",                   " <actor_name>",                                            scripts\actors::hp );
    self thread createCommand( "actor_model",   "Change actor's head and body",         " <actor_name> <body_model> <head_model>",                  scripts\actors::model );
    self thread createCommand( "actor_weapon",  "Attach weapon or model to tag",        " <actor_name> <tag_name> <weapon_mp/model/delete> <camo>", scripts\actors::eqipment );
    self thread createCommand( "actor_gopro",   "Fixed camera on actor tag",            " <actor_name> <tag_name> <x> <y> <z> <yaw> <pitch> <roll>",scripts\actors::gopro );
    self thread createCommand( "actor_fx",      "Play FX on tag or action",             " <actor_name> <fx_name> <tag_name> <when>",                scripts\actors::efx );
    // redo actor_follow
    // redo actor_walk
    // redo actor_name and look func

}

createCommand( command, desc, usage, callback, use_prefix )
{
    self endon( "disconnect" );

    prefix = "";
    if ( true_or_undef( use_prefix ) ) 	
        prefix = level.COMMAND_PREFIX + "_";

    self notifyOnPlayerCommand( command, prefix + command );
    setDvarIfUninitialized( prefix + command, level.COMMAND_COLOR + desc );

    for (;;)
    {
        self waittill( command );
        args = StrTok( getDvar( prefix + command ), " " );

        if ( args[0] == "help" ) {
            pront( "Usage: " + level.COMMAND_COLOR + "/" + prefix + command + usage );
            continue;
        }

        if ( args.size >= 1 ) 	self [[callback]]( args );
        else                    self [[callback]]();
    }
}

