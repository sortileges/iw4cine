/*
 *	SASS' CINEMATIC MOD - Misc file (#301)
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
		setDvar("sv_hostname", "IW4Cine - Sass' Cinematic Mod - #301");
		setDvar("g_TeamName_Allies", "allies");
		setDvar("g_TeamName_Axis", "axis");
		setDvar("jump_slowdownEnable", "0");

		setObjectiveText(game["attackers"], "IW4cine - Sass' Cinematic Mod \n Version : #301");
		setObjectiveText(game["defenders"], "IW4cine - Sass' Cinematic Mod \n Version : #301");
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
		thread Noclip();

		// Random stuff
		thread VerifyModel();
		thread water();
		thread dirt();
		thread earfquake();
		thread thermal();
		thread watermark();
		thread discord();

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
		level.scoreInfo["kill"]["value"] = getDvarFloat("mvm_score");
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

		self takeweapon(self getCurrentWeapon());
		self switchToWeapon(self getCurrentWeapon());
		wait .05;

		if (isSubStr(arguments[0], "akimbo"))
			self giveWeapon(arguments[0], GetCamoInt(arguments[1]), true);
		else self giveWeapon(arguments[0], GetCamoInt(arguments[1]), false);

		self switchToWeapon(arguments[0]);

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
			self thread teamPlayerCardSplash("callout_killcarrier", self, self.pers["team"]);
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
	wait .1;

	if (isSubStr(sec, "akimbo"))
		self _giveWeapon(sec, self.loadoutPrimaryCamo, true);
	else self _giveWeapon(sec, self.loadoutPrimaryCamo, false);
	wait .1;
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

Noclip()
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
