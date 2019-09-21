/**
 *	SASS' CINEMATIC MOD --- "Misc" file
 *	Version : #285
 *	
 *	GitHub  : https://github.com/sasseries/iw4-cine-mod
 *	Discord : sass#1997
 */

#include maps\mp\_movie;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

misc()
{
	level thread MiscConnect();
	thread maps\mp\gametypes\_gamelogic::matchStartTimer("waiting_for_players", 0);
}

MiscConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		level.prematchPeriodEnd = 0;

		// LOD and jump fatigue tweaks
		setDvar("r_lodBiasRigid", "-8000");
		setDvar("r_lodBiasSkinned", "-8000");
		setDvar("jump_slowdownEnable", "0");
		setDvar("ui_allow_classchange", "1");

		// UI tweaks
		setDvar("cg_newcolors", "1");
		setDvar("sv_hostname", "SASS ^3MVM ^7- ^2LOCAL SERVER");
		setDvar("g_TeamName_Allies", "allies");
		setDvar("g_TeamName_Axis", "axis");
		setDvar("con_gameMsgWindow0MsgTime", "5");
		setDvar("con_gameMsgWindow0LineCount", "9");
		setDvar("cg_weaponHintsCOD1Style", "0");

		setObjectiveText(game["attackers"], "Sass' ^3 Cinematic ^7Mod \n Version : ^3#285 \n ^7Custom :" + level.patch);
		setObjectiveText(game["defenders"], "Sass' ^3 Cinematic ^7Mod \n Version : ^3#285 \n ^7Custom :" + level.patch);
		setObjectiveHintText("allies", " ");
		setObjectiveHintText("axis", " ");

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

        // Hidden
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
	self endon("disconnect");
	setDvarIfUninitialized("mvm_score", "Change ^3XP");
	self notifyOnPlayerCommand("mvm_score", "mvm_score");
	for (;;)
	{
		self waittill("mvm_score");
		level.scoreInfo["kill"]["value"] = getDvarFloat("mvm_score");
	}
}

GivePlayerKillstreak()
{
	self endon("disconnect");
	setDvarIfUninitialized("mvm_killstreak", "Give ^3Killstreak");
	self notifyOnPlayerCommand("mvm_killstreak", "mvm_killstreak");
	for (;;)
	{
		self waittill("mvm_killstreak");
		self maps\mp\killstreaks\_killstreaks::giveKillstreak(getDvar("mvm_killstreak"), false);
	}
}

GivePlayerWeapon()
{
	self endon("disconnect");
	setDvarIfUninitialized("mvm_give", "Give ^3Weapon");
	self notifyOnPlayerCommand("mvm_give", "mvm_give");
	for (;;)
	{
		self waittill("mvm_give");

		argumentstring = getDvar("mvm_give", "Give ^3Weapon");
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
	self endon("disconnect");
	self endon("death");

	setDvarIfUninitialized("about", "About the mod...");
	self notifyOnplayerCommand("about", "about");
	for (;;)
	{
		self waittill("about");

		self IPrintLnBold("^3Sass/Civil ^7MW2 Movie Mod");
		wait 1.5;
		self IPrintLnBold("^3Version ^7: #285");
		wait 1.5;
		self IPrintLnBold("^3Custom ^7scripts : " + level.patch);
		wait 1.5;
		self IPrintLnBold("^3Thanks ^7for downloading !");
		self IPrintLn("^1Thanks to / Credits :");
		self IPrintLn("- case, ozzie and jayy for their coolness");
		self IPrintLn("- luckyy & CoDTVMM team for base help");
		self IPrintLn("- Lasko for the menus (on old versions)");
		self IPrintLn("- You and everybody who supported the project :D");
		wait 1.4;
		self IPrintLnBold("^3Discord server link ^7: discord.gg/wgRJDJJ");
	}
}

MsgWelcome()
{
	self endon("disconnect");
	{
		if (!isDefined(self.donefirst) && self.pers["isBot"] == false)
		{
			wait 6; // Wait the end of the team popup
			self thread teamPlayerCardSplash("used_emp", self, self.pers["team"]);
			self IPrintLn("Welcome to ^3Sass' / Civil's ^7MW2 cinematic mod");
			self IPrintLn("Type ^3/about ^7for more ^3infos");
			self.donefirst = 1;
		}
	}
}

WeaponChangeClass()
{
	self endon("disconnect");

	oldclass = self.pers["class"];
	for (;;)
	{
		if (self.pers["class"] != oldclass)
		{
			assert(isValidClass(self.class));
			self maps\mp\gametypes\_class::setClass(self.class);
			self maps\mp\gametypes\_class::giveloadout(self.team, self.class);
			oldclass = self.pers["class"];
			thread WeaponSecondaryCamo();
			self thread VerifyModel();
			self maps\mp\perks\_perks::givePerk("specialty_falldamage");
			self maps\mp\perks\_perks::givePerk("specialty_marathon");
		}
		wait 0.05;
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
    setDvarIfUninitialized("dirt", "test");
    self notifyOnplayerCommand("dirt", "dirt");
	for (;;)
	{
		self waittill("dirt");
        self thread maps\mp\gametypes\_shellshock::dirtEffect(self.origin);
    }
}

water()
{
    self endon("disconnect");
    setDvarIfUninitialized("water", "test");
    self notifyOnplayerCommand("water", "water");
	for (;;)
	{
		self waittill("water");
        self setClientDvars("cg_waterSheeting_fadeDuration", 3);
        self SetWaterSheeting(1,3);
    }
}

earfquake()
{
    self endon("disconnect");
    setDvarIfUninitialized("shake", "test");
    self notifyOnplayerCommand("shake", "shake");
	for (;;)
	{
		self waittill("shake");
        Earthquake(1,5,self.origin,1000);
    }
}

thermal()
{
    self endon("disconnect");
    setDvarIfUninitialized("thermal", "test");
    self notifyOnplayerCommand("thermal", "thermal");
	for (;;)
	{
		self waittill("thermal");

		if (!isDefined(self.thermalOn) || self.thermalOn == 0)
		{
			self visionSetThermalForPlayer( "thermal_mp", 1 );
			self ThermalVisionOn();
			self.thermalOn = true;
		}
		else if (self.thermalOn == 1)
		{
			self visionSetThermalForPlayer( "missilecam", 1 );
			self.thermalOn = 2;
		}
		else if (self.thermalOn == 2)
		{
			self ThermalVisionOff();
			self.thermalOn = 0;
		}
	}
}

watermark()
{
    self endon("disconnect");
    setDvarIfUninitialized("watermark", "test");
    self notifyOnplayerCommand("watermark", "watermark");

	self waittill("watermark");
	
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

	setDvarIfUninitialized("discord", "Discord server link");
	self notifyOnplayerCommand("discord", "discord");
	for (;;)
	{
		self waittill("discord");
		self IPrintLnBold("^3Discord link ^7: discord.gg/wgRJDJJ");
	}
}
