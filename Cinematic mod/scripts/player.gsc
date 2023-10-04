/*
 *      IW4 Cine
 *      Player-related functions
 */

//#include common_scripts\utility;
#include scripts\utils;

playerRegenAmmo()
{
    if(!level.PLAYER_AMMO) return;

    self thread regenAmmo();
    self thread regenEquip();
}

regenAmmo()
{
    self endon("disconnect");
    for (;;)
    {
        self notifyOnPlayerCommand( "reload", "+reload" );
        self waittill( "reload" );
        wait 2;

        self giveMaxAmmo( self getCurrentWeapon() );
    }
}

regenEquip()
{
    self endon("disconnect");
    for (;;)
    {
        self waittill( "grenade_fire", grenade, name );
        waittillframeend;

        self setWeaponAmmoClip( name, 1 );
        self GiveMaxAmmo( name );
    }
}

movementTweaks()
{
    if(!level.PLAYER_MOVEMENT) return;

    setDvar("jump_slowdownEnable", "0");
    self maps\mp\perks\_perks::givePerk("specialty_falldamage");
    self maps\mp\perks\_perks::givePerk("specialty_marathon");
}