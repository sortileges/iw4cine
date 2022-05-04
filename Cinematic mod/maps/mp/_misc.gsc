/*
 *	SASS' CINEMATIC MOD - Misc file (#304)
 */

#include maps\mp\gametypes\_gamelogic;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_movie;

misc()
{
	level thread MiscConnect();

	// Common precache, do not remove !!!
	PrecacheModel("defaultactor");
	PrecacheModel("projectile_rpg7");
	PrecacheModel("projectile_semtex_grenade_bombsquad");
	PrecacheMPAnim("pb_stand_alert");
	PrecacheMPAnim("pb_stand_death_chest_blowback");
	precacheItem("lightstick_mp");
}

MiscConnect()
{
	for (;;)
	{
		level waittill("connected", player);

		// LOD tweaks
		if (isSubStr(getDvar("version", "IW4x"))) {
			setDvar("r_lodBiasRigid", "-8000");
			setDvar("r_lodBiasSkinned", "-8000");
		}
		else {
			setDvar("r_lodBiasRigid", "-1000");
			setDvar("r_lodBiasSkinned", "-1000");
		}

		setDvar("cg_newcolors", "1");
		setDvar("sv_hostname", "IW4Cine - Sass' Cinematic Mod - #304");
		setDvar("g_TeamName_Allies", "allies");
		setDvar("g_TeamName_Axis", "axis");
		setDvar("jump_slowdownEnable", "0");

		setObjectiveText(game["attackers"], "IW4cine - Sass' Cinematic Mod \n Version : #304");
		setObjectiveText(game["defenders"], "IW4cine - Sass' Cinematic Mod \n Version : #304");
		setObjectiveHintText("allies", " ");
		setObjectiveHintText("axis", " ");
		game["strings"]["change_class"] = " ";

		player thread MiscSpawn();
	}
}

MiscSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		// No fall damage and unlimited sprint.
		self maps\mp\perks\_perks::givePerk("specialty_falldamage");
		self maps\mp\perks\_perks::givePerk("specialty_marathon");

		// Misc
		thread SetPlayerScore();
		thread GivePlayerKillstreak();
		thread GivePlayerWeapon();
		thread MsgAbout();
		thread MsgWelcome();
		thread WeaponChangeClass();
		thread WeaponSecondaryCamo();
		thread CreateClone();
		thread ClearBodies();
		thread LoadPos();
		thread FakeNoclip();

		// Random useless stuff
		thread VerifyModel();
		thread water();
		thread dirt();
		thread earfquake();
		thread thermal();
		thread watermark();
		thread discord();
		thread splashcard();
		thread twitchyweapon();
		thread blurscreen();

	}
}


SetPlayerScore()
{
	self endon("death");
	self endon("disconnect");
	
	setDvarIfUninitialized("mvm_score", "Change score per kill");
	self notifyOnPlayerCommand("mvm_score", "mvm_score");
	for (;;)
	{
		self waittill("mvm_score");

		maps\mp\gametypes\_rank::registerScoreInfo( "kill",  int(getDvarInt("mvm_score")));

		if ( isSubStr(getDvar("mvm_score"), "Change") || getDvarInt("mvm_score") >= 50 )
		{
			maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
			maps\mp\gametypes\_rank::registerScoreInfo( "execution", 100 );
			maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 50 );
			maps\mp\gametypes\_rank::registerScoreInfo( "defender", 50 );
			maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 25 );
			maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 50 );
			maps\mp\gametypes\_rank::registerScoreInfo( "double", 50 );
			maps\mp\gametypes\_rank::registerScoreInfo( "triple", 75 );
			maps\mp\gametypes\_rank::registerScoreInfo( "multi", 100 );
			maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 100 );
			maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 100 );
			maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 50 );
			maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 100 );
			maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 100 );
		}
		else 
		{
			maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "execution", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "defender", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "double", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "triple", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "multi", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 0 );
		}

	}
}

GivePlayerKillstreak()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_killstreak", "Give yourself a killstreak");
	self notifyOnPlayerCommand("mvm_killstreak", "mvm_killstreak");
	for (;;)
	{
		self waittill("mvm_killstreak");
		self maps\mp\killstreaks\_killstreaks::giveKillstreak(getDvar("mvm_killstreak"), false);
	}
}

GivePlayerWeapon()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_give", "Give yourself a weapon");
	self notifyOnPlayerCommand("mvm_give", "mvm_give");
	for (;;)
	{
		self waittill("mvm_give");

		argumentstring = getDvar("mvm_give");
		arguments = StrTok(argumentstring, " ,");

		if ( isEquipment(arguments[0]) )
		{
			if ( isSecOffhand(arguments[0]))
			{
				self iPrintLn("Changing tactical to ^8" + arguments[0] + "^7...");
				self takeAllSecOffhands();
				wait 0.5; // An artifical delay is necessary for the new equipment to register. Same happens with primaries. Why? Idk.
				self setOffhandSecondaryClass( getOffhandName(arguments[0]) );
			}
			else 
			{
				self iPrintLn("Changing lethal to ^8" + arguments[0] + "^7...");
				self takeAllPrimOffhands();
				wait 1; 
				self SetOffhandPrimaryClass( getOffhandName(arguments[0]) );
			}
			self maps\mp\perks\_perks::givePerk(getOffhandName(arguments[0]));
			self giveWeapon(arguments[0]);
		}
		else
		{
			self takeweapon(self getCurrentWeapon());
			self switchToWeapon(self getCurrentWeapon());
			wait .05;
			if (isSubStr(arguments[0], "akimbo"))
				self giveWeapon(arguments[0], GetCamoInt(arguments[1]), true);
			else self giveWeapon(arguments[0], GetCamoInt(arguments[1]), false);
			self switchToWeapon(arguments[0]);
		}
	}
}

MsgAbout()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("about", "About the mod...");
	self notifyOnplayerCommand("about", "about");
	for (;;)
	{
		self waittill("about");

		self IPrintLnBold("Sass' MW2 Cinematic Mod");
		wait 1.5;
		self IPrintLnBold("Version : #301");
		wait 1.5;
		self IPrintLnBold("Thanks for downloading !");
		self IPrintLn("^1Thanks to / Credits :");
		self IPrintLn("- case, ozzie and ODJ for their coolness");
		self IPrintLn("- luckyy, zura and the CoDTVMM team for base code");
		self IPrintLn("- LASKO & simon for the menus");
		self IPrintLn("- You and everybody who supported the project!");
		wait 1.5;
		self IPrintLnBold("Discord server link : discord.gg/wgRJDJJ");
	}
}

MsgWelcome()
{
	self endon("death");
	self endon("disconnect");
	{
		if (!isDefined(self.donefirst) && self.pers["isBot"] == false)
		{
			thread matchStartTimer("waiting_for_teams", 0);
			thread matchStartTimer("match_starting_in", 0 );
			level.prematchPeriodEnd = -1;
			wait 6;
			self thread teamPlayerCardSplash("one_from_defcon", self, self.pers["team"]);
			self IPrintLn("Welcome to ^3Sass' MW2 cinematic mod");
			self IPrintLn("Type ^3/about ^7for more infos");
			self.donefirst = 1;
		}
	}
}

WeaponChangeClass()
{
	self endon("death");
	self endon("disconnect");

	oldclass = self.pers["class"];
	for(;;)
	{
		if(self.pers["class"] != oldclass)
		{
			self maps\mp\gametypes\_class::giveloadout(self.pers["team"],self.pers["class"]);
			oldclass = self.pers["class"];
			self maps\mp\perks\_perks::givePerk("specialty_falldamage");
			self maps\mp\perks\_perks::givePerk("specialty_marathon");
			self thread WeaponSecondaryCamo();
		}
		wait .05;
	}
}

WeaponSecondaryCamo()
{
	sec = self.secondaryWeapon;
	self takeweapon(sec);

	if (isSubStr(sec, "akimbo"))
		self _giveWeapon(sec, self.loadoutPrimaryCamo, true);
	else self _giveWeapon(sec, self.loadoutPrimaryCamo, false);
}


CreateClone()
{
	self endon("disconnect");
	self endon("death");
	setDvarIfUninitialized("clone", "Spawn a clone of yourself");
	self notifyOnplayerCommand("clone", "clone");
	for (;;)
	{
		self waittill("clone");

		if ( getDvar("clone") == "1") {
			self PrepareInHandModel();
			wait .1;
			self ClonePlayer(1);
		}
		else {
			self.weaptoattach delete();
			self ClonePlayer(1);
		}
		setDvar("clone", "Spawn a clone of yourself");
	}
}

ClearBodies()
{
	self endon("disconnect");
	self endon("death");
	setDvarIfUninitialized("clearbodies", "Clear all dead bodies");
	self notifyOnplayerCommand("clearbodies", "clearbodies");
	for (;;)
	{
		self waittill("clearbodies");

		self iPrintLn("Cleaning up...");
		for (i = 0; i < 15; i++)
		{
			clone = self ClonePlayer(1);
			clone delete();
			wait .1;
		}
	}
}

VerifyModel()
{
	self endon("disconnect");
	if (isDefined(self.modelalready))
	{
		self detachAll();
		self[[game[self.lteam + "_model"][self.lmodel]]]();
	}
}

dirt()
{
	self endon("disconnect");
	setDvarIfUninitialized("test_dirt", "Test command");
	self notifyOnplayerCommand("test_dirt", "test_dirt");
	for (;;)
	{
		self waittill("test_dirt");
		self thread maps\mp\gametypes\_shellshock::dirtEffect(self.origin);
	}
}

water()
{
	self endon("disconnect");
	setDvarIfUninitialized("test_water", "Test command");
	self notifyOnplayerCommand("test_water", "test_water");
	for (;;)
	{
		self waittill("test_water");
		self setClientDvars("cg_waterSheeting_fadeDuration", 3);
		self SetWaterSheeting(1,3);
	}
}

earfquake()
{
	self endon("disconnect");
	setDvarIfUninitialized("test_shake", "Test command");
	self notifyOnplayerCommand("test_shake", "test_shake");
	for (;;)
	{
		self waittill("test_shake");
		Earthquake(1,5,self.origin,1000);
	}
}

thermal()
{
	self endon("disconnect");
	setDvarIfUninitialized("test_thermal", "Test command");
	self notifyOnplayerCommand("test_thermal", "test_thermal");
	for (;;)
	{
		self waittill("test_thermal");

		if (!isDefined(self.thermalOn) || self.thermalOn == 0) {
			self visionSetThermalForPlayer( "thermal_mp", 1 );
			self ThermalVisionOn();
			self.thermalOn = 1;
		}
		else if (self.thermalOn == 1) {
			self visionSetThermalForPlayer( "missilecam", 1 );
			self.thermalOn = 2;
		}
		else if (self.thermalOn == 2) {
			self ThermalVisionOff();
			self.thermalOn = 0;
		}
	}
}

watermark()
{
	self endon("disconnect");
	setDvarIfUninitialized("test_watermark", "Test command");
	self notifyOnplayerCommand("test_watermark", "test_watermark");

	self waittill("test_watermark");

	watermark = newClientHudElem(self);
	watermark.horzAlign ="right";
	watermark.vertAlign ="top";
	watermark.x = -782;
	watermark.y = 72;
	watermark.font = "Objective";
	watermark.fontscale = 0.84;
	watermark.alpha = 0.8;
	watermark.hideWhenInMenu = true;
	watermark setText("Sass' Cinematic Mod");

}

splashcard()
{
	self endon("disconnect");
	setDvarIfUninitialized("test_splash", "Test command");
	self notifyOnplayerCommand("test_splash", "test_splash");
	for (;;)
	{
		self waittill("test_splash");
		self thread teamPlayerCardSplash("changed_defcon", self, self.pers["team"]);
	}
}

twitchyweapon()
{
	self endon("disconnect");
	setDvarIfUninitialized("test_twitch", "Test command");
	self notifyOnplayerCommand("test_twitch", "test_twitch");
	for (;;)
	{
		self waittill("test_twitch");
		self StunPlayer(3);
	}
}

blurscreen()
{
	self endon("disconnect");
	setDvarIfUninitialized("test_blur", "Test command");
	self notifyOnplayerCommand("test_blur", "test_blur");
	for (;;)
	{
		self waittill("test_blur");
		self SetBlurForPlayer(8,0.5);
		wait 2;
		self SetBlurForPlayer(0,0.5);
	}
}

discord()
{
	self endon("disconnect");
	self endon("death");
	setDvarIfUninitialized("discord", "Link : discord.gg/wgRJDJJ");
	self notifyOnplayerCommand("discord", "discord");
	for (;;)
	{
		self waittill("discord");
		self IPrintLnBold("^3Discord link : ^7discord.gg/wgRJDJJ");
	}
}

FakeNoclip()
{
	self endon("disconnect");
	self endon("death");
	self endon("killnoclip");
	setDvarIfUninitialized("noclip2", "");
	self notifyOnPlayerCommand("noclip2", "noclip2");
	maps\mp\gametypes\_spectating::setSpectatePermissions();
	for (;;)
	{
		self waittill("noclip2");
		self openMenu("noclip");
		self allowSpectateTeam("freelook", true);
		self.sessionstate = "spectator";
		self waittill("noclip2");
		self closeMenu("noclip");
		self.sessionstate = "playing";
		self allowSpectateTeam("freelook", false);
	}
}

LoadPos()
{
	self freezecontrols(true);
	wait .05;
	self setPlayerAngles(self.spawn_angles);
	self setOrigin(self.spawn_origin);
	wait .05;
	self freezecontrols(false);
}

takeAllSecOffhands()
{
	self takeweapon( "smoke_grenade_mp" );
	self takeweapon( "flash_grenade_mp" );
	self takeweapon( "concussion_grenade_mp" );
}

takeAllPrimOffhands()
{
	self takeweapon( "flare_mp" );
	self takeweapon( "throwingknife_mp" );
	self takeweapon( "c4_mp" );
	self takeweapon( "claymore_mp" );
	self takeweapon( "semtex_mp" );
	self takeweapon( "frag_grenade_mp" );
}

getOffhandName(item)
{
	switch(item)
	{
		case "flash_grenade_mp":
			return "flash";
		case "smoke_grenade_mp":
			return "smoke";
		case "concussion_grenade_mp":
			return "concussion_grenade_mp";
		case "flare_mp":
			return "flare";
		case "c4_mp":
			return "c4_mp";
		case "claymore_mp":
			return "claymore_mp";
		case "semtex_mp":
			return "semtex_mp";
		case "frag_grenade_mp":
			return "frag_grenade_mp";
		case "throwingknife_mp":
			return "throwingknife_mp";
		case "lightstick_mp":
			return "lightstick_mp";
		default:
			return "other";
	}
}

isSecOffhand(item)
{
	switch(item)
	{
		case "flash_grenade_mp":
		case "smoke_grenade_mp":
		case "concussion_grenade_mp":
			return true;
		default:
			return false;
	}
}

isEquipment(item)
{
	switch(item)
	{
		case "flare_mp":
		case "throwingknife_mp":
		case "c4_mp":
		case "claymore_mp":
		case "semtex_mp":
		case "frag_grenade_mp":
		case "flash_grenade_mp":
		case "smoke_grenade_mp":
		case "concussion_grenade_mp":
		case "lightstick_mp":
			return true;
		default:
			return false;
	}
}

checkIfWeirdWeapon(weapon, camo)
{
	if(isSubStr( weapon, "magpul_masada" ) && isDefined(camo) && isValidCamoAlias(camo) ) 
		return "weapon_magpul_masada";
	if(isSubStr( weapon, "steyr" ) && isDefined(camo) && isValidCamoAlias(camo) ) 
		return "weapon_steyr";
	if(isSubStr( weapon, "aa12" ) && isDefined(camo) && isValidCamoAlias(camo) ) 
		return "weapon_aa12_2";
	if(isSubStr( weapon, "famas" ) && isDefined(camo) && isValidCamoAlias(camo) ) 
		return "weapon_famas_f1";
	if(isSubStr( weapon, "m14ebr" ) && isDefined(camo) && isValidCamoAlias(camo) ) 
		return "weapon_m14ebr";
	else return weapon;
}

checkIfCamoAvailable(weapon, camo)
{
	weaponName = StrTok(weapon, "_");
	ref = weaponName[0];
	switch( weaponName[0] )
	{
		case "beretta":
		case "beretta393":
		case "coltanaconda":
		case "deserteagle":
		case "glock":
		case "usp":
		case "m79":
		case "rpg":
		case "at4":
		case "model1887":
		case "ranger":
		case "riotshield":
		case "stinger":
			return "";
		default:
			return GetCamoName(camo);
	}
}

isValidCamoAlias(camo)
{
	switch(camo)
	{
		case "woodland":
		case "desert":
		case "arctic":
		case "digital":
		case "urban":
		case "red":
		case "blue":
		case "fall":
			return true;
		default:
			return false;
	}
}