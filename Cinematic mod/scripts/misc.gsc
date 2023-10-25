/*
 *      IW4cine
 *      Miscellaneous functions
 */

#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\utils;
#include maps\mp\gametypes\_class;

clone()
{
    self ClonePlayer(1);
}

drop()
{
    self endon( "disconnect" );
    self endon( "death" );
    self dropItem( self getCurrentWeapon() );
}

class_swap()
{
    self endon("disconnect");

    old_class = self.pers["class"];
    for(;;)
    {
        if( self.pers["class"] != old_class )
        {
            self maps\mp\gametypes\_class::giveloadout( self.pers["team"], self.pers["class"] );
            self scripts\player::movementTweaks();
            self scripts\misc::reset_models();
            old_class = self.pers["class"];
        }
        waitframe();
    }
}

// As for as equipment goes, going from a lethal that doesn't depend --
// -- on scripts to one that does will not work. (e.g TK to Claymore)
// Not gonna bother because I highly doubt anybody does that anyway.
give( args )
{
    weapon  = args[0];
    camo    = defaultcase( isDefined( args[1] ), args[1], 0 );

    if ( isValidEquipment( weapon ) )
    {
        if ( isValidOffhand( weapon ) )
        {
            pront( "Changing tactical to " + level.COMMAND_COLOR + weapon );
            self take_offhands_tac();
            waitsec();
            self setOffhandSecondaryClass( get_offhand_name( weapon ) );
        }
        else 
        {
            pront( "Changing lethal to " + level.COMMAND_COLOR + weapon );
            self take_offhands_leth();
            waitsec();
            self SetOffhandPrimaryClass( get_offhand_name( weapon ) );
        }
        self maps\mp\perks\_perks::givePerk( get_offhand_name( weapon ) );
        self giveWeapon( weapon );
    }
    else if ( isValidWeapon( weapon ) )
    {
        self dropItem( self getCurrentWeapon() );
        skipframe();;

        self giveWeapon( weapon, camo_int( camo ), is_akimbo( weapon ) );

        self switchToWeapon( weapon );
    }
    else pront( "wtf is a '" + weapon  + "'??");
}

clear_bodies()
{
    for (i = 0; i < 15; i++)
    {
        clone = self ClonePlayer(1);
        clone delete();
        skipframe();;
    }
}

expl_bullets()
{
    for(;;)
    {
        self waittill( "weapon_fired" );
        if( GetDvarInt("eb_explosive") > 0 ) RadiusDamage( at_crosshair( self ), GetDvarInt("eb_explosive"), 800, 800, self );
    }
}

magc_bullets()
{
    for(;;)
    {
        self waittill("weapon_fired");
        foreach ( player in level.players )
        {
            if ( inside_fov( self, player, GetDvarInt("eb_magic") ) && player != self )
                player thread [[level.callbackPlayerDamage]]( self, self, self.health, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "torso_upper", 0 );
        }
        foreach (actor in level.actors)
        {
            if ( inside_fov( self, actor["hitbox"], GetDvarInt("eb_magic") ) )
                actor["hitbox"] notify( "damage", actor["hitbox"].health, self );
        }
    }
}

viewhands( args )
{
    pront( "Setting viewmodel to " + level.COMMAND_COLOR + args[0] );
    self setViewmodel( args[0] );
    self.pers["viewmodel"] = args[0];
}

reset_models()
{
    if( isdefined ( self.pers["fakeModel"] ) && self.pers["fakeModel"] != false ) {
        skipframe();;
        self detachAll();
        self [[game[self.pers["fakeTeam"] + "_model"][self.pers["fakeModel"]]]]();
    }

    if( isdefined ( self.pers["viewmodel"] ) )
        self setViewmodel( self.pers["viewmodel"] );
}

// Toggles
toggle_holding()
{
    level.BOT_WEAPHOLD ^= 1;
    pront( "Holding weapons on death: " + level.COMMAND_COLOR + bool(level.BOT_WEAPHOLD) );

    if( !level.BOT_WEAPHOLD ) {
        foreach( player in level.players )
            player.replica delete();
    }
}

toggle_freeze()
{
    level.BOT_MOVE ^= 1;
    bots_tweaks();
    pront( "Frozen bots: " + level.COMMAND_COLOR + bool(level.BOT_SPAWN_MOVE) );
}


// Spawners
spawn_model( args )
{
    model = args[0];
    anima = args[1];
    prop = spawn( "script_model", self.origin );
    prop.angles = ( 0, self.angles[1], 0);
    prop setModel( model );

    if( isDefined( anima ) )
        prop scriptModelPlayAnim(anima);

    pront( "Spawned model " + level.COMMAND_COLOR + model );
}

spawn_fx( args )
{
    fx = args[0];
    level._effect[fx] = loadfx( fx );
    playFX( level._effect[fx], at_crosshair( self ) );
}

// Fog and Vision
change_vision( args )
{
    vision = args[0];
    self VisionSetNakedForPlayer( vision );
    pront("Vision changed to : " + vision);
}

change_fog( args )
{
    start       = int(args[0]);
    end         = int(args[1]);
    red         = int(args[2]);
    green       = int(args[3]);
    blue        = int(args[4]);
    opacity     = int(args[5]);
    transition  = int(args[6]);
    setExpFog(start, end, red, green, blue, opacity, transition);
}


welcome()
{
    self endon( "disconnect" );

    self waittill( "spawned_player" );
    self freezeControls( false );
    wait 2;
    self thread teamPlayerCardSplash( "revived", self, self.pers["team"] );
}

about()
{
    self _giveWeapon( "killstreak_predator_missile_mp" );
	self SwitchToWeapon( "killstreak_predator_missile_mp" );
    while(self getCurrentWeapon() != "killstreak_predator_missile_mp")
        waitframe();

    wait 0.55;

    self setBlurForPlayer( 15, 0.5 );
    self VisionSetNakedForPlayer( "mpintro", 0.4 );

    text = [];
    text[0] = elem( -50, 0.8, "hudbig",     "^3IW4cine - #400", 30);
    text[1] = elem( -33, 1,   "default",    "2015 - 2023", 30 );
    text[2] = elem( -9,  1.1, "small",      "^3Immensely and forever thankful for :", 20 );
    text[3] = elem( 7.5, 1.3, "default",    "Zura, luckyy, CoDTV MM Team, kruumy", 15 );
    text[4] = elem( 25,  1.23,"default",    "case, Ozzie, LASKO, Jayy, simon, the whole sm2 squad", 11 );
    text[5] = elem( 41,  1,   "default",    "The Ody Island, forgive, expert, JTAG, NOOB TEAM, 3500, PUNK, Openminded, and kilos of SSRIs", 9 );
    text[6] = elem( 170, 0.5, "smallfixed", "Press ^3[{weapnext}]^7 to close", 20 );

    self waittill_any( "weapon_switch_started" ,"weapon_fired", "death");

    foreach( t in text ) t SetPulseFX( 0, 0, 150 );

    self switchToWeapon( self getLastWeapon() );
    self setBlurForPlayer( 0, 0.35 );
    self VisionSetNakedForPlayer( getDvar( "mapname" ), 0.5 );

    waitsec();
    self TakeWeapon( "killstreak_predator_missile_mp" );
    foreach( t in text ) t destroy();
}

elem( offset, size, font, text, pulse )
{
    elem = newClientHudElem( self );
    elem.horzAlign = "center";
    elem.vertAlign = "middle";
    elem.alignX = "center";
    elem.alignY = "middle";
    elem.y = offset;
    elem.font = font;
    elem.fontscale = size;
    elem.alpha = 1;
    elem.color = (1,1,1);
    elem setText( text );
    elem SetPulseFX( pulse, 900000000, 9000 );
    return elem;
}