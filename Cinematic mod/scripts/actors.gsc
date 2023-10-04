/*
 *      IW4cine
 *      Actors functions
 */

#include precache;
#include scripts\utils;
#include scripts\misc;

add( args )
{
    base_body = defaultcase( isDefined( args[0] ), args[0], "defaultactor" );
    base_head = defaultcase( isDefined( args[1] ), args[1], "tag_origin" );
    base_anim = defaultcase( isDefined( args[2] ), args[2], "pb_stand_remotecontroller" );
    base_death= defaultcase( isDefined( args[3] ), args[3], "pb_stand_death_chest_blowback" );

    level.actorCount++;

    newactor = [];
    newactor["name"] = level.ACTOR_NAME_PREFIX + level.actorCount;

    newactor["body"] = spawn( "script_model", at_crosshair( self ) );
    newactor["body"].angles = self.angles + ( 0, 180, 0 );
    newactor["body"] EnableLinkTo();
    newactor["body"] setModel( base_body );
    newactor["body"] scriptModelPlayAnim( base_anim );

    newactor["savedo"] = newactor.origin;
    newactor["saveda"] = newactor.angles;

    newactor["head"] = spawn( "script_model", newactor["body"] GetTagOrigin("j_spine4") );
    newactor["head"] setModel( base_head );
    newactor["head"].angles = newactor["body"].angles + ( 270, 0, 270 );
    newactor["head"] linkTo( newactor["body"], "j_spine4") ;
    newactor["head"] scriptModelPlayAnim( base_anim );

    
    newactor["hitbox"] = spawn( "script_model", newactor["body"].origin + ( 0, 0, 40 ) );
    newactor["hitbox"] setModel( "com_plasticcase_enemy" );
    newactor["hitbox"] Solid();
    newactor["hitbox"].angles = (90, 0, 0);
    newactor["hitbox"] hide();
    newactor["hitbox"].name = level.ACTOR_NAME_PREFIX + level.actorCount;
    newactor["hitbox"] setCanDamage(1);
    newactor["hitbox"].health = 120;
    newactor["hitbox"].maxhealth = 120;
    newactor["hitbox"] linkto( newactor );

    newactor["anim_death"] = base_death;
    newactor["anim_base"] = base_anim;

    newactor["fx"]["hurt"]              = [];
    newactor["fx"]["hurt"].efx          = undefined;
    newactor["fx"]["hurt"].where        = undefined;
    newactor["fx"]["death"]             = [];
    newactor["fx"]["death"].efx         = "flesh_body";
    newactor["fx"]["death"].where       = "j_spine4";
    newactor["fx"]["actorback"]         = [];
    newactor["fx"]["actorback"].efx     = undefined;
    newactor["fx"]["actorback"].where   = undefined;

    newactor["attached"] = [];

    newactor thread track_damage();
    level.actors[level.actorCount] = newactor;

    pront( "[" + newactor["name"] + "] * " + level.COMMAND_COLOR + "Spawned");

}

copy( args )
{
    name = args[0];
    foreach( actor in level.actors )
    {
        if ( select_ents( actor, name, self ) ) {
            newactor = [];
            newactor.base_body = actor["body"].model;
            newactor.base_head = actor["head"].model;
            newactor.anim_base = actor["anim_base"];
            newactor.anim_death = actor["anim_death"];
            add( newactor );
        }
    }
}

prepare_gopro()
{
    level.gopro = spawn( "script_model", ( 9999, 9999, 9999 ) );
    level.gopro setModel( "tag_origin" );
    level.gopro.origin = self getOrigin();
    level.gopro.angles = self getPlayerAngles();
    level.gopro.linked = 0;
    level.gopro enableLinkTo();

    waittillframeend;
    level.gopro.object = spawn( "script_model", ( 9999, 9999, 9999 ) );
    level.gopro.object setModel( "projectile_rpg7" );
    level.gopro.object.origin = level.gopro.origin;
    level.gopro.object.angles = ( level.gopro.angles - ( 15, 0, 0 ) );

    waittillframeend;
    level.gopro.object linkTo( level.gopro, "tag_origin" );
}

gopro( args )
{
    action  = args[0];
    tag     = args[1];
    x       = args[2];
    y       = args[3];
    z       = args[4];
    roll    = args[5];
    pitch   = args[6];
    yaw     = args[7];

    if ( action == "delete" )
    {
        level.gopro unlink();
        level.gopro.linked = 0;
        level.gopro MoveTo( ( 49999, 49999, 49999 ), .1 );
    }
    else if ( action == "on" )
    {
        self CameraLinkTo( level.gopro, "tag_origin" );
        setDvar( "cg_drawGun", 0 );
        self allowSpectateTeam( "freelook", true );
        self.sessionstate = "spectator";
    }
    else if ( action == "off" )
    {
        self CameraUnlink();
        setDvar( "cg_drawGun", 1 );
        self allowSpectateTeam( "freelook", false );
        self.sessionstate = "playing";
    }
    else
    {
        foreach( actor in level.actors )
        {
            if ( select_ents( actor, action, self ) ) 
            {
                if ( level.gopro.linked ) {
                    level.gopro unlink();
                    level.gopro.linked ^= 1;
                }
                level.gopro.origin = actor GetTagOrigin( tag );
                level.gopro.angles = actor GetTagAngles( tag );
                skipframe();
                level.gopro linkTo( actor, tag, ( int(x), int(y), int(z) ), ( int(roll), int(pitch), int(yaw) ) );
                level.gopro.linked = 1;
            }
        }
    }
}

track_damage()
{
    killer = undefined;
    while (self["hitbox"].health > 0)
    {
        self["hitbox"] waittill("damage", amount, attacker, dir, point, type);
        killer = attacker;
        killer thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("standard");

        if ( isDefined(killer) && isPlayer(killer) )
            self["hitbox"].health -= amount;

        if(self["hitbox"].health > 0) self play_efx( "hurt" );
    }

    self["body"] scriptModelPlayAnim( self["anim_death"] );
    self["head"] scriptModelPlayAnim( self["anim_death"] );

    self["body"] playSound( "generic_death_american_" + randomIntRange( 1, 8 ) );
    self["body"] play_efx( "death" );

    if(level.ACTOR_SHOW_KILLFEED)
        obituary(killer, killer, killer getCurrentWeapon(), "MOD_RIFLE_BULLET"); // Figure this out later

    killer maps\mp\gametypes\_rank::scorePopup( ( level.scoreInfo["kill"]["value"] ) , 0 );
}

back()
{
    foreach( actor in level.actors )
    {
        actor["body"] MoveTo( actor["savedo"], 0.1, 0, 0 );
        actor["body"] RotateTo( actor["saveda"], 0.1, 0, 0 );
        actor["body"] scriptModelPlayAnim( actor["anim_base"] );
        actor["head"] scriptModelPlayAnim( actor["anim_base"] );

        if ( actor["hitbox"].health <= 0 ) {
            actor["hitbox"].health = actor["hitbox"].maxhealth;
            actor thread track_damage();
        }     

        actor["body"] play_efx( "actorback" );
        pront( "[" + actor["name"] + "] * " + level.COMMAND_COLOR + "Reset" );
    }
}

move( args )
{
    name = args[0];
    foreach( actor in level.actors )
    {
        if ( select_ents( actor, name, self ) ) {
            actor["body"] MoveTo( self.origin, 0.1 );
            actor["body"] RotateTo( self.angles, 0.1 );
        }
    }
}

playanim( args )
{
    name = args[0];
    anima = args[1];
    foreach( actor in level.actors )
    {
        if ( select_ents( actor, name, self ) ) {
            actor["body"] scriptModelPlayAnim( anima );
            actor["head"] scriptModelPlayAnim( anima );
        }
    }
}

deathanim( args )
{
    name = args[0];
    anima = args[1];
    foreach( actor in level.actors )
    {
        if ( select_ents( actor, name, self ) ) 
            actor["anim_death"] = anima;
    }
}

model( args )
{
    name = args[0];
    body = args[1];
    head = args[2];
    foreach( actor in level.actors )
    {
        if ( select_ents( actor, name, self ) ) 
        {
            if ( body == "head" )
                actor["head"] setModel( head );

            else if ( body == "body" )
                actor setModel( head );

            else {
                actor setModel( body );
                actor["head"] setModel( head );
            }
            pront( "[" + actor["name"] + "] * Model swapped -> " + level.COMMAND_COLOR + body + " " + head );
        }
    }
}

hp( args )
{
    name = args[0];
    hp =   args[1];
    foreach( actor in level.actors )
    {
        if ( select_ents( actor, name, self ) ) {
            actor["hitbox"].maxhealth = int( hp );
            actor["hitbox"].health = actor["hitbox"].maxhealth;
            pront( "[" + actor["name"] + "] * Health -> " + level.COMMAND_COLOR + actor["hitbox"].maxhealth );
        }
    }
}

eqipment( args )
{
    name =  args[0];
    tag =   args[1];
    model = args[2];
    camo =  args[3];

    foreach( actor in level.actors )
    {
        if ( select_ents( actor, name, self ) ) 
        {
            if ( isDefined( actor["attached"][tag] ) )
                actor["attached"][tag] delete();

            actor["attached"][tag] = spawn( "script_model", actor GetTagOrigin( tag ) );
            actor["attached"][tag] linkTo ( actor, tag, (0, 0, 0), (0, 0, 0) );

            if ( isSubStr( model, "_mp" ) ) // Can't think of a xmodel that has _mp in its name so it SHOULD be a weapon
            {
                hidetags = GetWeaponHideTags( model );
                replica = getWeaponModel( model, camo_int( camo ) );

                actor["attached"][tag] setModel( replica );
                for (i = 0; i < hidetags.size; i++) 
                    actor["attached"][tag] HidePart( hidetags[i],  replica );

                pront( "[" + actor["name"] + "] * Attached -> " + level.COMMAND_COLOR + replica + " to " + tag );
            }
            else if ( model != "delete" ) {
                actor["attached"][tag] setModel( model );
                pront( "[" + actor["name"] + "] * Attached -> " + level.COMMAND_COLOR + model + " to " + tag );
            }
        }
    }
}

efx( args )
{
    name = args[0];
    fx =   args[1];
    tag =  args[2];
    when = args[3];
    foreach( actor in level.actors )
    {
        if ( select_ents( actor, name, self ) ) {

            if ( true_or_undef( when ) || when == "now" ) {
                playFx( level._effect[fx], actor["body"] GetTagOrigin(tag));
                playFx( level._effect[fx], actor["head"] GetTagOrigin(tag));
            }

            else 
            {
                actor["fx"][when].efx = level._effect[fx];
                actor["fx"][when].where = tag;
                pront( "[" + actor["name"] + "] * FX -> " + level.COMMAND_COLOR + fx + " to " + tag);
            }
        }
    }
}

play_efx( when )
{
    if( isdefined( self["fx"][when].efx ) )
        playFx( level._effect[self["fx"][when].efx], self["body"] GetTagOrigin( self["fx"][when].where ) );
}