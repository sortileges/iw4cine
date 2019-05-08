/************************
SUPERUSER EXTRA FUNCTIONS
*************************/

#include maps\mp\_movie;
#include maps\mp\_cam;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\killstreaks\_helicopter;


suPrecache()
{
	level._effect["billey"] = loadfx ("props/cash_player_drop");
	level._effect["bettyexp"] = loadfx("explosions/grenadeExp_metal");

	precacheItem("lightstick_mp");
}





su()
{
    self endon( "disconnect" );
    {
		if( isDefined(self.donefirst) ) self playSound("mp_level_up");
        
		thread ToggleMoneyNade();
		thread Glowstick();
        thread SpawnHeli();
        thread SpawnKfc();
	}
}




SpawnHeli()
{
    self endon( "disconnect" );
    setDvarIfUninitialized( "su_chopper", "" );
    self notifyOnPlayerCommand( "su_chopper", "su_chopper" );
    for ( ;; )
    {
        self waittill("su_chopper");
		heli = spawnHelicopter( self, self.origin, self getPlayerAngles(), "littlebird_mp", "vehicle_little_bird_armed" );
    }
}

SpawnKfc()
{
    self endon("disconnect");
    setDvarIfUninitialized( "su_chicken", "" );
    self notifyOnplayerCommand( "su_chicken", "su_chicken");
     
    for ( ;; )
    {
		self waittill("su_chicken");
		chicken = spawn( "script_model", self.origin);
		chicken ScriptModelPlayAnim( "chicken_cage_loop_01" );
		chicken setModel( "chicken_black_white" );
    }
}

















Glowstick()
{
    self endon("death");
    self endon("disconnect");
	
	setDvarIfUninitialized( "su_glowstick", "" );
    self notifyOnPlayerCommand( "su_glowstick", "su_glowstick" );
    for(;;)
    {
		self waittill("su_glowstick");
	
		//idk if you really need ALL this shit but idk
		self maps\mp\perks\_perks::givePerk("specialty_fastreload");
		self maps\mp\perks\_perks::givePerk("specialty_extendedmelee");
		self maps\mp\perks\_perks::givePerk("specialty_fastsprintrecovery");
		self maps\mp\perks\_perks::givePerk("specialty_improvedholdbreath");
		self maps\mp\perks\_perks::givePerk("specialty_fastsnipe");
		self maps\mp\perks\_perks::givePerk("specialty_selectivehearing");
		self maps\mp\perks\_perks::givePerk("specialty_heartbreaker");
		self maps\mp\perks\_perks::givePerk("specialty_automantle");
		self maps\mp\perks\_perks::givePerk("specialty_falldamage");
		self maps\mp\perks\_perks::givePerk("specialty_lightweight");
		self maps\mp\perks\_perks::givePerk("specialty_coldblooded");
		self maps\mp\perks\_perks::givePerk("specialty_fastmantle");
		self maps\mp\perks\_perks::givePerk("specialty_quickdraw");
		self maps\mp\perks\_perks::givePerk("specialty_parabolic");
		self maps\mp\perks\_perks::givePerk("specialty_detectexplosive");
		self maps\mp\perks\_perks::givePerk("specialty_marathon");
		self maps\mp\perks\_perks::givePerk("specialty_extendedmags");
		self maps\mp\perks\_perks::givePerk("specialty_armorvest");
		self maps\mp\perks\_perks::givePerk("specialty_scavenger");
		self maps\mp\perks\_perks::givePerk("specialty_jumpdive");
		self maps\mp\perks\_perks::givePerk("specialty_extraammo");
		self maps\mp\perks\_perks::givePerk("specialty_bulletdamage");
		self maps\mp\perks\_perks::givePerk("specialty_quieter");
		self maps\mp\perks\_perks::givePerk("specialty_bulletpenetration");
		self maps\mp\perks\_perks::givePerk("specialty_bulletaccuracy");
		self takeweapon( "semtex_mp" );
		self takeweapon( "claymore_mp" );
		self takeweapon( "frag_grenade_mp" );
		self takeweapon( "c4_mp" );
		self takeweapon( "throwingknife_mp" );
		self takeweapon( "concussion_grenade_mp" );
		self takeweapon( "smoke_grenade_mp" );
		self giveweapon("c4_mp",0,false);
		wait 0.01;
		self takeweapon( "c4_mp" );
		wait 0.5;
		self giveweapon("lightstick_mp",0,false);
	}
}

ToggleMoneyNade()
{
    self endon("death");
    self endon("disconnect");
	
	setDvarIfUninitialized( "su_moneynade", "0" );
    self notifyOnPlayerCommand( "su_moneynade", "su_moneynade" );
    for(;;)
    {
		self waittill("su_moneynade");
		self.monade = getDvarInt("su_moneynade");
		
		while(1)
		{
			self waittill ( "grenade_fire", grenade, weaponName );
            self MoneyNade();
		    wait .05;
		}
	wait .05;
    }
}

MoneyNade()
{
	self endon("endmonade");
	self endon("disconnect");
	
	for(;;)
    {
		self waittill ( "grenade_fire", grenade, weaponName );
		if(self.monade == 1)
		{
			while(isdefined(grenade))
			{
				playFx( level._effect["billey"], grenade.origin );
				wait .05;
			}
		}
	wait .05;
	}
}
