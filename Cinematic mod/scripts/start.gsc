/*
 * 		IW4cine
 *		Entry point
 */

init()
{
    defaults::load_defaults();
    precache::common_precache();
    precache::custom_precache();
    precache::fx_precache();

    level.actors = [];
    level thread waitForHost();
}

waitForHost()
{
    level waittill( "connecting", player );

    player scripts\commands::registerCommands();

    scripts\utils::skip_prematch();
    scripts\utils::match_tweaks();
    scripts\utils::lod_tweaks();
    scripts\utils::hud_tweaks();
    scripts\utils::score_tweaks();
    scripts\utils::bots_tweaks();
    scripts\actors::prepare_gopro();

    player thread scripts\misc::welcome();
    player thread scripts\ui::await();
    player thread onPlayerSpawned();
}


onPlayerSpawned()
{
    self endon("disconnect");

    self scripts\player::playerRegenAmmo();
    self thread scripts\actors::names();
    self thread scripts\misc::class_swap();

    for(;;)
    {
        self waittill("spawned_player");

        // Only stuff that gets reset/removed because of death goes here
        self scripts\player::movementTweaks();
        self scripts\misc::reset_models();
    }
}