/*
 *      IW4cine
 *      Hooks for existing functions
 */

#include scripts\utils;
#include maps\mp\gametypes\_damage;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
    replaceFunc( maps\mp\gametypes\_weapons::deletePickupAfterAWhile,   ::_weapons_deletePickupAfterAWhile);
    replaceFunc( maps\mp\gametypes\_weapons::watchPickup,               ::_weapons_watchPickup);
    replaceFunc( maps\mp\gametypes\_weapons::dropWeaponForDeath,        ::_weapons_dropWeaponForDeath);
    replaceFunc( maps\mp\gametypes\_rank::scorePopup,                   ::_rank_scorePopup);
    replaceFunc( maps\mp\gametypes\_music_and_dialog::init,             ::_music_and_dialog_init);
}

// _weapons.gsc - Makes dropped weapons disappear after 5 seconds instead of 60
_weapons_deletePickupAfterAWhile()
{
    self endon("death");

    wait 5;

    if ( !isDefined( self ) )
        return;

    self delete();
}

// _weapons.gsc - Makes picked up then dropped weapons call the modifed deletePickupAfterAWhile() function
_weapons_watchPickup()
{
    self endon("death");

    weapname = self maps\mp\gametypes\_weapons::getItemWeaponName();

    while(1)
    {
        self waittill( "trigger", player, droppedItem );
        
        if ( isdefined( droppedItem ) )
            break;
    }

    droppedWeaponName = droppedItem maps\mp\gametypes\_weapons::getItemWeaponName();
    if ( isdefined( player.tookWeaponFrom[ droppedWeaponName ] ) )
    {
        droppedItem.owner = player.tookWeaponFrom[ droppedWeaponName ];
        droppedItem.ownersattacker = player;
        player.tookWeaponFrom[ droppedWeaponName ] = undefined;
    }
    droppedItem thread _weapons_watchPickup();
    droppedItem thread _weapons_deletePickupAfterAWhile();

    if ( isdefined( self.ownersattacker ) && self.ownersattacker == player )
        player.tookWeaponFrom[ weapname ] = self.owner;
    else
        player.tookWeaponFrom[ weapname ] = undefined;
}


// _weapons.gsc - Handles bots holding guns when dead, removes grace period for picking up weapons
_weapons_dropWeaponForDeath( attacker )
{
    weapon = self.lastDroppableWeapon;

    if ( isdefined( self.droppedDeathWeapon ) )
        return;

    if ( !isdefined( weapon ) || weapon == "none" || !self hasWeapon( weapon ) )
        return;

    if ( weapon != "riotshield_mp" )
    {
        if ( level.BOT_WEAPHOLD )
            item = 0; // Not very clean; purposefully breaks the dropItem() part so nothing is dropped

        else
        {
            if ( !(self AnyAmmoForWeaponModes( weapon )) )
                return;

            clipAmmoR = self GetWeaponAmmoClip( weapon, "right" );
            clipAmmoL = self GetWeaponAmmoClip( weapon, "left" );
            if ( !clipAmmoR && !clipAmmoL )
                return;

            stockAmmo = self GetWeaponAmmoStock( weapon );
            stockMax = WeaponMaxAmmo( weapon );
            if ( stockAmmo > stockMax )
                stockAmmo = stockMax;

            item = self dropItem( weapon );
            item ItemWeaponSetAmmo( clipAmmoR, stockAmmo, clipAmmoL );
        }
    }
    else
    {
        item = self dropItem( weapon );	
        if ( !isDefined( item ) )
            return;
        item ItemWeaponSetAmmo( 1, 1, 0 );
    }

    self.droppedDeathWeapon = true;

    item.owner = self;
    item.ownersattacker = attacker;

    item thread _weapons_watchPickup();
    item thread _weapons_deletePickupAfterAWhile();

    detach_model = getWeaponModel( weapon );

    if ( !isDefined( detach_model ) )
        return;

    if( isDefined( self.tag_stowed_back ) && detach_model == self.tag_stowed_back )
        self maps\mp\gametypes\_weapons::detach_back_weapon();

    if ( !isDefined( self.tag_stowed_hip ) )
        return;

    if( detach_model == self.tag_stowed_hip )
        self maps\mp\gametypes\_weapons::detach_hip_weapon();
}

//  _rank.gsc - Makes score popup always yellow and last 2.5 seconds, and makes "0" a valid score
_rank_scorePopup( amount, bonus, hudColor, glowAlpha )
{
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );

    self notify( "scorePopup" );
    self endon( "scorePopup" );

    self.xpUpdateTotal += amount;
    self.bonusUpdateTotal += bonus;

    wait 0.05;

    if ( self.xpUpdateTotal < 0 )
        self.hud_scorePopup.label = &"";
    else
        self.hud_scorePopup.label = &"MP_PLUS";

    self.hud_scorePopup.color = (1,1,0.5);
    self.hud_scorePopup.glowColor = hudColor;
    self.hud_scorePopup.glowAlpha = glowAlpha;

    self.hud_scorePopup setValue(self.xpUpdateTotal);
    self.hud_scorePopup.alpha = 0.85;
    self.hud_scorePopup thread maps\mp\gametypes\_hud::fontPulse( self );

    increment = max( int( self.bonusUpdateTotal / 20 ), 1 );
        
    if ( self.bonusUpdateTotal )
    {
        while ( self.bonusUpdateTotal > 0 )
        {
            self.xpUpdateTotal += min( self.bonusUpdateTotal, increment );
            self.bonusUpdateTotal -= min( self.bonusUpdateTotal, increment );
            
            self.hud_scorePopup setValue( self.xpUpdateTotal );
            
            wait 0.05;
        }
    }	
    else 
        wait 2.5;

    self.hud_scorePopup fadeOverTime( 0.75 );
    self.hud_scorePopup.alpha = 0;

    self.xpUpdateTotal = 0;
}

// _music_and_dialog.gsc - Removes most musics and dialogs
_music_and_dialog_init()
{
    level thread maps\mp\gametypes\_music_and_dialog::onPlayerConnect();
    level thread maps\mp\gametypes\_music_and_dialog::onLastAlive();
    level thread maps\mp\gametypes\_music_and_dialog::musicController();
    level thread maps\mp\gametypes\_music_and_dialog::onGameEnded();
    level thread maps\mp\gametypes\_music_and_dialog::onRoundSwitch();
}