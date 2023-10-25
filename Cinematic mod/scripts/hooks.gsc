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
    replaceFunc( maps\mp\gametypes\_damage::delayStartRagdoll,          ::_damage_delayStartRagdoll);
    replaceFunc( maps\mp\gametypes\_damage::handleNormalDeath,          ::_damage_handleNormalDeath);
    replaceFunc( maps\mp\gametypes\_hud_message::actionNotify,          ::_hud_message_actionNotify);
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
    else player.tookWeaponFrom[ weapname ] = undefined;
}


// _weapons.gsc - Handles bots holding guns when dead, removes grace period for picking up weapons
_weapons_dropWeaponForDeath( attacker )
{
    weapon = self.lastDroppableWeapon;

    if ( !isdefined( weapon ) || weapon == "none" || !self hasWeapon( weapon ) || isdefined( self.droppedDeathWeapon )  )
        return;

    if ( weapon == "riotshield_mp" )
    {
        item = self dropItem( weapon );	
        if ( !isDefined( item ) )
            return;
        item ItemWeaponSetAmmo( 1, 1, 0 );
    }
    else
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

    wait .05;

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
            wait .05;
        }
    }	
    else wait 2.5;

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

// _damage.gsc - Makes ragdolls start later much than vanilla, delete after given time
_damage_delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
    if ( !isDefined( ent ) || ent isRagDoll() )
        return;

    deathAnim = ent getCorpseAnim();

    if( level.BOT_LATERAGDOLL )
            timeMult = 0.9;
    else timeMult = 0.65;

    wait ( getanimlength( deathAnim ) * timeMult );
    ent startragdoll( 1 );

    if ( level.BOT_AUTOCLEAR > 0 ) {
        wait level.BOT_AUTOCLEAR;
        ent delete();
    }
}

// _damage.gsc - Remove youkilled/killedby splashes, remove stats, persistence and assists stuff
_damage_handleNormalDeath( lifeId, attacker, eInflictor, sWeapon, sMeansOfDeath )
{
    attacker thread maps\mp\_events::killedPlayer( lifeId, self, sWeapon, sMeansOfDeath );

    if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
        attacker playLocalSound( "bullet_impact_headshot_2" );

    value = undefined;
    attacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", value );

    lastKillStreak = attacker.pers["cur_kill_streak"];

    attacker.pers["cur_death_streak"] = 0;
    if ( isAlive( attacker ) )
        attacker.pers["cur_kill_streak"]++;

    maps\mp\gametypes\_gamescore::givePlayerScore( "kill", attacker, self );
    maps\mp\_skill::processKill( attacker, self );

    if ( isDefined( level.ac130player ) && level.ac130player == attacker )
        level notify( "ai_killed", self );

    level notify ( "player_got_killstreak_" + attacker.pers["cur_kill_streak"], attacker );

    if ( isAlive( attacker ) )
        attacker thread maps\mp\killstreaks\_killstreaks::checkKillstreakReward( attacker.pers["cur_kill_streak"] );

    attacker notify ( "killed_enemy" );

    // Just in case
    self.attackers = [];
}

// _hud_message.gsc - Bye bye splashes
_hud_message_actionNotify()
{
    return;
}