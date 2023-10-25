/*
 *      IW4cine
 *      Bots functions
 */

#include common_scripts\utility;
#include scripts\utils;
#include maps\mp\_utility;
#include maps\mp\gametypes\_class;


add( args )
{
    weapon  = args[0];
    team    = args[1];
    camo    = args[2];

    ent = addTestClient();
    ent persistence();
    ent spawnme(self, weapon, team, camo);

    create_kill_params();
}

persistence()
{
    self.pers["isBot"]      = true;     // is bot
    self.pers["isStaring"]  = false;    // is in "staring mode"
    self.pers["fakeModel"]  = false;    // has the bot's model been changed?
}

spawnme( owner, weapon, team, camo )
{
    while ( !isdefined( self.pers["team"] ) ) skipframe();

    weapon = legacy_classnames( weapon );
    if( !isValidPrimary( getBaseWeaponName( weapon ) ) && !isValidSecondary( getBaseWeaponName( weapon ) ) )
            weapon = "ak47_mp";

    if ( ( team == "allies" || team == "axis" ) && isdefined( team ) )
            self notify( "menuresponse", game["menu_team"], team );
    else if ( !isdefined( team ) )
        self notify( "menuresponse", game["menu_team"], level.otherTeam[level.players[0].team] ); // level.players[0] might fuck up in round-based modes, I'll see
    else {
        self notify( "menuresponse", game["menu_team"], level.otherTeam[level.players[0].team] );
        camo = team;
    }

    if ( !isdefined( camo ) || !isValidCamo( camo ) )
        camo = 0;

    skipframe();

    self notify( "menuresponse", "changeclass", "class0" );
    loadout = create_loadout( weapon, camo );
    self thread create_spawn_thread( scripts\bots::give_loadout_on_spawn, loadout );
    self thread create_spawn_thread( scripts\bots::attach_weapons, loadout );

    self waittill( "spawned_player" );
    self setOrigin( at_crosshair( owner ) );
    self setPlayerAngles( owner.angles + ( 0, 180, 0 ) );

    self save_spawn();
    self thread create_spawn_thread( scripts\utils::load_spawn );
    self thread create_spawn_thread( scripts\misc::reset_models );
    self scripts\player::playerRegenAmmo();

    if(level.BOT_SPAWNCLEAR)
        self thread create_spawn_thread( scripts\misc::clear_bodies );
}

move( args )
{
    name = args[0];
    foreach( player in level.players )
    {
        if ( select_ents( player, name, self ) ) {
            player setOrigin( at_crosshair( self ) );
            player save_spawn();
        }
    }
}

aim( args )
{
    name = args[0];
    foreach( player in level.players )
    {
        if ( select_ents( player, name, self ) ) 
        {
            player thread doaim();
            wait 0.5;
            player notify( "stopaim" );
        }
    }
}

stare( args )
{
    name = args[0];
    foreach( player in level.players )
    {
        if ( select_ents( player, name, self ) ) 
        {
            player.pers["isStaring"] ^= 1;
            if ( player.pers["isStaring"] ) player thread doaim();
            else player notify( "stopaim" );
        }
    }
}

model( args )
{
    name  = args[0];
    model = args[1];
    team  = args[2];
    foreach( player in level.players )
    {
        if ( select_ents( player, name, self ) ) 
        {
            player.pers["fakeTeam"]  = team;
            player.pers["fakeModel"] = model;

            player detachAll();
            skipframe();
            player[[game[team + "_model"][model]]]();

            if( isdefined ( player.pers["viewmodel"] ) )
                player setViewmodel( player.pers["viewmodel"] );
        }
    }
}

doaim()
{
    self endon( "disconnect" );
    self endon( "stopaim" );

    for (;;)
    {
        wait .05;   // waittillframeend makes the loop too fast (?) and the game yeets itself off the mortal plane from whence it came
        target = undefined;

        foreach( player in level.players )
        {
            if ( ( player == self ) || ( level.teamBased && self.pers["team"] == player.pers["team"] ) || ( !isAlive( player) ) )
                continue;

            if ( isDefined( target ) ) {
                if ( closer ( self getTagOrigin( "j_head" ), player getTagOrigin( "j_head" ), target getTagOrigin( "j_head" ) ) )
                    target = player;
            }
            else target = player;
        }

        if ( isDefined( target ) )
            self setPlayerAngles( VectorToAngles( ( target getTagOrigin( "j_head" ) ) - ( self getTagOrigin( "j_head" ) ) ) );
    }
}

kill( args )
{
    name = args[0];
    mode = args[1];
    foreach( player in level.players )
    {
        if ( select_ents( player, name, self ) )
        {
            parameters  = strTok( level.killparams[mode], ":" );
            fx          = parameters[0];
            tag         = player getTagOrigin( parameters[1] );
            hitloc      = parameters[2];

            playFXOnTag( getFX( fx ), self, tag );
            level.players[0] thread [[level.callbackPlayerDamage]]( player, player, player.health, 8, "MOD_SUICIDE", self getCurrentWeapon(), tag, tag, hitloc, 0 );
            
        }
    }
}

// This absolutely sucks redo me
delay(args)
{
    //time = args[0];
    setDvarIfUninitialized("scr_killcam_time",      level.BOT_SPAWN_DELAY/2);
    setDvarIfUninitialized("scr_killcam_posttime",  level.BOT_SPAWN_DELAY/2);
}

create_loadout( weapon, camo )
{
    loadout         = spawnstruct();
    loadout.primary = weapon;
    loadout.camo    = camo;
    return loadout;
}

attach_weapons( loadout )
{
    wait .1; // take the wait from misc\reset_models() into account
    if ( level.BOT_WEAPHOLD && self is_bot() )
    {
        self.replica = getWeaponModel( loadout.primary, camo_int(loadout.camo) );
        self attach( self.replica, "tag_weapon_right", true );

        hidetags = GetWeaponHideTags( loadout.primary );
        for ( i = 0; i < hidetags.size; i++ )
            self HidePart( hidetags[i], self.replica );
    }
}

create_kill_params()
{
    level.killparams             = [];
    level.killparams["body"]     = "flesh_body:j_spine4:body";
    level.killparams["head"]     = "flesh_head:j_head:head";
    level.killparams["shotgun"]  = "flesh_body:j_knee_ri:body"; // REDO ME!!
    level.killparams["cash"]     = "money:j_spine4:body";
}

give_loadout_on_spawn( loadout )
{
    self takeAllWeapons();
    self giveWeapon( loadout.primary, camo_int( loadout.camo ), is_akimbo( loadout.primary ) );
    self setSpawnWeapon( loadout.primary );
    self detachAll();
    self maps\mp\gametypes\_teams::playerModelForWeapon( getBaseWeaponName( loadout.primary ) , "usp" );
}