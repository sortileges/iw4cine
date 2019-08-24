/**
 *	SASS' CINEMATIC MOD --- "Movie" file
 *	Version : #280
 *	
 *	GitHub  : https://github.com/sasseries/iw4-cine-mod
 *	Discord : sass#1997
 */

#include maps\mp\_patch;
#include maps\mp\gametypes\_hud_message;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#using_animtree("destructibles");

movie()
{
	level thread MovieInit();
}

MovieInit()
{
	level._effect["cash"] = loadfx("props/cash_player_drop");
	level._effect["blood"] = loadfx("impacts/flesh_hit_body_fatal_exit");
	level thread PrimaryDvars();
}

PrimaryDvars()
{
	for (;;)
	{
		level waittill("connected", player);

		// Removed because they were causing B&W to stay during demos on rare occasions
		//level.prematchPeriodEnd = 0;
		//thread maps\mp\gametypes\_gamelogic::matchStartTimer( "waiting_for_players", 0 );


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
		setDvar("con_gameMsgWindow0MsgTime", "9");
		setDvar("con_gameMsgWindow0LineCount", "9");

		setObjectiveText(game["attackers"], "Sass' ^3 Cinematic ^7Mod \n Version : ^3#280 \n ^7Patch :" + level.patch);
		setObjectiveText(game["defenders"], "Sass' ^3 Cinematic ^7Mod \n Version : ^3#280 \n ^7Patch :" + level.patch);
		setObjectiveHintText("allies", "Welcome to ^3Sass' Cinematic Mod");
		setObjectiveHintText("axis", "Welcome to ^3Sass' Cinematic Mod");

		player.pers["isBot"] = false;
		game["dialog"]["gametype"] = undefined;

		player thread MovieSpawn();
	}
}

MovieSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		self thread WelcomeMsg();

		// No fall damage and unlimited sprint.
		self maps\ mp\ perks\ _perks::givePerk("specialty_falldamage");
		self maps\ mp\ perks\ _perks::givePerk("specialty_marathon");

		// Grenade cam reset
		setDvar("camera_thirdperson", "0");
		self show();

		// Regeneration	
		thread RegenAmmo();
		thread RegenEquip();
		thread RegenSpec();

		// Bots
		thread BotSpawn();
		thread BotWeapon();
		thread BotSetup();
		thread BotStare();
		thread BotAim();
		thread BotModel();
		thread VerifyModel();

		// Explosive Bullets
		thread EBClose();
		thread EBMagic();

		// "Kill" command
		thread BotKill();
		thread EnableLink();

		// Environement
		thread SpawnProps();
		thread SpawnEffects();
		thread TweakFog();
		thread SetVisions();

		// Misc
		thread PointsPerKill();
		thread GibeKillStreak();
		thread CoD4Give();
		thread clone();
		thread about();
		thread loadPos();
		thread noclip();
		thread Instaclass();
		thread SecondaryCamo();
		thread clearBodies();

	}
}

RegenAmmo()
{
	for (;;)
	{
		self notifyOnPlayerCommand("reload", "+reload");
		self waittill("reload");
		wait 1;
		if (self.pers["rAmmo"] == "true")
		{
			currentWeapon = self getCurrentWeapon();
			self giveMaxAmmo(currentWeapon);
		}
	}
}

RegenEquip()
{
	for (;;)
	{
		self notifyOnPlayerCommand("frag", "+frag");
		self waittill("frag");
		currentOffhand = self GetCurrentOffhand();
		self.pers["equ"] = currentOffhand;
		wait 2;
		if (self.pers["rEquip"] == "true")
		{
			self setWeaponAmmoClip(currentOffhand, 9999);
			self GiveMaxAmmo(currentOffhand);
		}
	}
}

RegenSpec()
{
	for (;;)
	{
		self notifyOnPlayerCommand("smoke", "+smoke");
		self waittill("smoke");
		currentOffhand = self GetCurrentOffhand();
		self.pers["equSpec"] = currentOffhand;
		wait 2;
		if (self.pers["rSpec"] == "true")
		{
			self giveWeapon(self.pers["equSpec"]);
			self giveMaxAmmo(currentOffhand);
			self setWeaponAmmoClip(currentOffhand, 9999);
		}
	}
}

BotSpawn()
{
	self endon("disconnect");
	self endon("death");
	setDvarIfUninitialized("mvm_bot_spawn", "class team ^8- ^3Spawns a bot");
	self notifyOnPlayerCommand("mvm_bot_spawn", "mvm_bot_spawn");
	for (;;)
	{
		self waittill("mvm_bot_spawn");

		for (i = 0; i < 1; i++)
		{
			ent[i] = addtestclient();
			ent[i].pers["isBot"] = true;
			ent[i].isStaring = false;
			ent[i] thread BotPrestige();
			ent[i] thread BotDoSpawn(self);
		}
	}
}

BotDoSpawn(owner)
{
	self endon("disconnect");

	argumentstring = getDvar("mvm_bot_spawn", "");
	arguments = StrTok(argumentstring, " ,");

	while (!isdefined(self.pers["team"])) wait .05;

	self notify("menuresponse", game["menu_team"], arguments[1]);
	wait .1;

	if (arguments[0] == "m40a3")
		self notify("menuresponse", "changeclass", "class" + 9);
	else if (arguments[0] == "inter")
		self notify("menuresponse", "changeclass", "class" + 8);
	else if (arguments[0] == "ak74u")
		self notify("menuresponse", "changeclass", "class" + 7);
	else if (arguments[0] == "mp5")
		self notify("menuresponse", "changeclass", "class" + 6);
	else if (arguments[0] == "m4")
		self notify("menuresponse", "changeclass", "class" + 5);
	else if (arguments[0] == "riot")
		self notify("menuresponse", "changeclass", "class" + 4);
	else if (arguments[0] == "barrett")
		self notify("menuresponse", "changeclass", "class" + 3);
	else if (arguments[0] == "ak47")
		self notify("menuresponse", "changeclass", "class" + 2);
	else if (arguments[0] == "ump")
		self notify("menuresponse", "changeclass", "class" + 1);
	else if (arguments[0] == "deagle")
		self notify("menuresponse", "changeclass", "class" + 0);
	else
		self notify("menuresponse", "changeclass", "class" + 0);

	self waittill("spawned_player");

	start = owner getTagOrigin("tag_eye");
	end = anglestoforward(owner getPlayerAngles()) * 1000000;
	spawnpos = BulletTrace(start, end, true, owner)["position"];
	self.pers["isBot"] = true;
	self.isStaring = false;

	wait .05;
	self setOrigin(spawnpos);
	self setPlayerAngles(owner.angles + (0, 180, 0));
	self thread savespawn();

}

BotSetup()
{
	self endon("death");
	self endon("disconnect");
	setDvarIfUninitialized("mvm_bot_setup", "name ^8- ^3Moves the bot to your xhair");
	self notifyOnPlayerCommand("mvm_bot_setup", "mvm_bot_setup");
	for (;;)
	{
		self waittill("mvm_bot_setup");

		start = self getTagOrigin("tag_eye");
		end = anglestoforward(self getPlayerAngles()) * 1000000;
		newpos = BulletTrace(start, end, true, self)["position"];

		foreach(player in level.players)
		{
			if (isSubStr(player.name, getDvar("mvm_bot_setup", "")))
			{
				player setOrigin(newpos);
				player thread savespawn();
			}
		}
	}
}

BotWeapon()
{
	self endon("death");
	self endon("disconnect");
	setDvarIfUninitialized("mvm_bot_weapon", "name weapon camo ^8- ^3Gives weapon to bot");
	self notifyOnPlayerCommand("mvm_bot_weapon", "mvm_bot_weapon");
	for (;;)
	{
		self waittill("mvm_bot_weapon");
		argumentstring = getDvar("mvm_bot_weapon", "");
		arguments = StrTok(argumentstring, " ,");

		weaponHideTagList = GetWeaponHideTags(arguments[1]);
		foreach(player in level.players)
		{
			if (player.pers["isBot"] == true)
			{
				if (isSubStr(player.name, arguments[0]))
				{
					if (isDefined(player.newBotWeapon))
						player.newBotWeapon Delete();
					player takeWeapon(player GetCurrentWeapon());
					wait 0.05;
					player.newBotWeapon = spawn("script_model", player GetTagOrigin("j_gun"));
					player.newBotWeapon linkTo(player, "j_gun", (0, 0, 0), (0, 0, 0));
					player.newBotWeapon setModel((getWeaponModel(arguments[1])) + GetCamoName(arguments[2]));
					for (i = 0; i < weaponHideTagList.size; i++)
					{
						player.newBotWeapon HidePart(weaponHideTagList[i], (getWeaponModel(arguments[1])) + GetCamoName(arguments[2]));
					}

					// Giving weapon through these doesn't seem to work.
					player giveWeapon(arguments[1], 0, false);
					player switchToWeapon(arguments[1]);

					player DeleteWeapOnDeath();

				}
			}
		}
	}
}

DeleteWeapOnDeath()
{
	self waittill("death");
	self.newBotWeapon Unlink();
	self.newBotWeapon delete();
}

BotAim()
{
	self endon("death");
	self endon("disconnect");
	setDvarIfUninitialized("mvm_bot_aim", "name ^8- ^3Bot aims at its clostest enemy");
	self notifyOnPlayerCommand("mvm_bot_aim", "mvm_bot_aim");
	for (;;)
	{
		self waittill("mvm_bot_aim");

		foreach(player in level.players)
		{
			if (isSubStr(player.name, getDvar("mvm_bot_aim", "")))
			{
				player thread BotDoAim();
				wait(0.4);
				player notify("stopaim");
				player thread savespawn();
			}
		}
	}
}

BotStare()
{
	self endon("death");
	self endon("disconnect");
	setDvarIfUninitialized("mvm_bot_stare", "name ^8- ^3Bot stares at its clostest enemy");
	self notifyOnPlayerCommand("mvm_bot_stare", "mvm_bot_stare");
	for (;;)
	{
		self waittill("mvm_bot_stare");

		foreach(player in level.players)
		{
			if (isSubStr(player.name, getDvar("mvm_bot_stare", "")))
			{
				if (player.isStaring == false)
				{
					player thread BotDoAim();
					player.isStaring = true;
				}
				else if (player.isStaring == true)
				{
					player notify("stopaim");
					player.isStaring = false;
				}
				player thread savespawn();
			}
		}
	}
}

BotDoAim()
{
	self endon("disconnect");
	self endon("stopaim");
	for (;;)
	{
		wait .01;
		aimAt = undefined;
		foreach(player in level.players)
		{
			if ((player == self) || (level.teamBased && self.pers["team"] == player.pers["team"]) || (!isAlive(player)))
				continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else
				aimAt = player;
		}
		if (isDefined(aimAt))
		{
			self setplayerangles(VectorToAngles((aimAt getTagOrigin("j_head")) - (self getTagOrigin("j_head"))));
		}
	}
}

BotModel()
{
	self endon("death");
	self endon("disconnect");
	setDvarIfUninitialized("mvm_bot_model", "name MODEL team ^8- ^3Changes bot model");
	self notifyOnPlayerCommand("mvm_bot_model", "mvm_bot_model");
	for (;;)
	{
		self waittill("mvm_bot_model");
		argumentstring = getDvar("mvm_bot_model", "");
		arguments = StrTok(argumentstring, " ,");

		foreach(player in level.players)
		{
			if (isSubStr(player.name, arguments[0]))
			{
				player thread BotModelChange(arguments[1], arguments[2]);
			}
		}
	}
}

BotModelChange(lmodel, lteam)
{
	self endon("disconnect");
	self endon("death");
	{
		self.lteam = lteam;
		self.lmodel = lmodel;
		self detachAll();
		self[[game[self.lteam + "_model"][self.lmodel]]]();

		self.modelalready = true;
		wait .1;
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

EBClose()
{
	self endon("death");
	self endon("disconnect");
	setDvarIfUninitialized("mvm_eb_close", "*toggle* ^8- ^3Toggles 'close' explosive bullets");

	self notifyOnPlayerCommand("mvm_eb_close", "mvm_eb_close");
	for (;;)
	{
		self waittill("mvm_eb_close");

		if (!isDefined(self.ebclose) || self.ebclose == false)
		{
			self thread ebCloseScript();
			self iPrintLn("^3Close ^7explosive bullets ^8- ^2ON");
			self.ebclose = true;
		}
		else if (self.ebclose == true)
		{
			self notify("eb1off");
			self iPrintLn("^3Close ^7explosive bullets ^8-  ^1OFF");
			self.ebclose = false;
		}
	}
}

EBMagic()
{
	self endon("death");
	self endon("disconnect");
	setDvarIfUninitialized("mvm_eb_magic", "*toggle* ^8- ^3Toggles 'magic' explosive bullets");

	self notifyOnPlayerCommand("mvm_eb_magic", "mvm_eb_magic");
	for (;;)
	{
		self waittill("mvm_eb_magic");

		if (!isDefined(self.ebmagic) || self.ebmagic == false)
		{
			self thread ebMagicScript();
			self iPrintLn("^3Magic ^7explosive bullets ^8- ^2ON");
			self.ebmagic = true;
		}
		else if (self.ebmagic == true)
		{
			self notify("eb2off");
			self iPrintLn("^3Magic ^7explosive bullets ^8- ^1OFF");
			self.ebmagic = false;
		}
	}

}

ebCloseScript()
{
	self endon("eb1off");
	self endon("disconnect");

	while (1)
	{
		self waittill("weapon_fired");
		my = self gettagorigin("j_head");
		trace = bullettrace(my, my + anglestoforward(self getplayerangles()) * 100000, true, self)["position"];
		playfx(level.expbullt, trace);
		dis = distance(self.origin, trace);
		if (dis < 101) RadiusDamage(trace, dis, 200, 50, self);
		RadiusDamage(trace, 100, 800, 50, self);
	}
}

ebMagicScript()
{
	self endon("disconnect");
	self endon("eb2off");

	for (;;)
	{
		wait .01;
		aimAt = undefined;
		foreach(player in level.players)
		{
			if (player == self)
				continue;
			if (!isAlive(player))
				continue;
			if (level.teamBased && self.pers["team"] == player.pers["team"])
				continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else
				aimAt = player;
		}
		if (isDefined(aimAt))

			self waittill("weapon_fired");
		aimAt thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_UNKNOWN", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "HEAD", 0);
	}
}


BotKill()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_bot_kill", "name mode - ^3Kills bots/player");
	self notifyOnPlayerCommand("mvm_bot_kill", "mvm_bot_kill");
	for (;;)
	{

		self waittill("mvm_bot_kill");

		argumentstring = getDvar("mvm_bot_kill", "");
		arguments = StrTok(argumentstring, " ,");

		foreach(player in level.players)
		{
			if (isSubStr(player.name, arguments[0]))
			{
				if (isDefined(self.linke))
				{
					player PrepareInHandModel();
					player takeweapon(player getCurrentWeapon()); // removes the falling weapon	
					wait .05;
				}
				player thread BotDoKill(arguments[1], self);
			}
		}
	}
}

BotDoKill(mode, attacker)
{
	self endon("disconnect");
	self endon("death");

	{

		if (mode == "head")
		{
			playFx(level._effect["blood"], self getTagOrigin("j_head"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "head", 0);
		}
		else if (mode == "body")
		{
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "body", 0);
		}
		else if (mode == "shotgun")
		{
			vec = anglestoforward(self.angles);
			end = (vec[0] * (-300), vec[1] * (-300), vec[2] * (-300));
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", "spas12_mp", self.origin + end, self.origin, "left_foot", 0);
		}
		else if (mode == "cash")
		{
			playFx(level._effect["cash"], self getTagOrigin("j_spine4"));
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "body", 0);
		}
	}
}

EnableLink()
{
	self endon("death");
	self endon("disconnect");
	setDvarIfUninitialized("mvm_bot_holdgun", "*toggle* - ^3Toggle bots holding guns while dying");

	self notifyOnPlayerCommand("mvm_bot_holdgun", "mvm_bot_holdgun");
	for (;;)
	{
		self waittill("mvm_bot_holdgun");

		if (!isDefined(self.linke))
		{
			foreach(player in level.players)
			{
				player iPrintLn("^3Bots hold weapon on ^7mvm_bot_kill ^3 : ^2TRUE");
				self.linke = true;
			}
		}
		else if (self.linke == true)
		{
			foreach(player in level.players)
			{
				player iPrintLn("^3Bots hold weapon on ^7mvm_bot_kill ^3 : ^1FALSE");
				self.linke = undefined;
			}
		}
	}
}

TweakFog()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_env_fog", "start half red green blue trans - ^3Custom fog");
	self notifyOnPlayerCommand("mvm_env_fog", "mvm_env_fog");
	for (;;)
	{
		self waittill("mvm_env_fog");

		argumentstring = getDvar("mvm_env_fog", "startdist halfwaydist red green blue transtime");
		arguments = StrTok(argumentstring, " ,");
		setExpFog(int(arguments[0]), int(arguments[1]), int(arguments[2]), int(arguments[3]), int(arguments[4]), 1, int(arguments[5]));
		wait .2;
	}
}


SetVisions()
{
	self endon("disconnect");
	self endon("death");

	setDvarIfUninitialized("mvm_env_colors", "name - ^3Changes filmtweaks");
	self notifyOnPlayerCommand("mvm_env_colors", "mvm_env_colors");
	for (;;)
	{
		self waittill("mvm_env_colors");

		self VisionSetNakedForPlayer(getDvar("mvm_env_colors", "visname"));
		self IPrintLn("^3Colors ^7changed to : ^7" + getDvar("mvm_env_colors", ""));
	}
}

SpawnProps()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_env_prop", "^3Spawns a prop ^7(check the .txt)");
	self notifyOnPlayerCommand("mvm_env_prop", "mvm_env_prop");
	for (;;)
	{
		self waittill("mvm_env_prop");
		prop = spawn("script_model", self.origin);
		prop.angles = self.angles;
		prop setModel(getDvar("mvm_env_prop", ""));
		self IPrintLn("^7" + getDvar("mvm_env_prop", "") + " ^3spawned ! ");
	}
}

SpawnEffects()
{
	self endon("disconnect");

	setDvarIfUninitialized("mvm_env_fx", "Spawns an ^3effect");
	self notifyOnplayerCommand("mvm_env_fx", "mvm_env_fx");
	for (;;)
	{
		self waittill("mvm_env_fx");
		start = self getTagOrigin("tag_eye");
		end = anglestoforward(self getPlayerAngles()) * 1000000;
		fxpos = BulletTrace(start, end, true, self)["position"];
		level._effect["spawnedfx"] = loadfx((getDvar("mvm_env_fx", "")));
		playFX(level._effect["spawnedfx"], fxpos);
	}
}

CoD4Give()
{
	self endon("disconnect");
	setDvarIfUninitialized("mvm_give", "Give ^3Weapon");
	self notifyOnPlayerCommand("mvm_give", "mvm_give");
	for (;;)
	{
		self waittill("mvm_give");

		argumentstring = getDvar("mvm_give", "Give ^3Weapon");
		arguments = StrTok(argumentstring, " ,");
		wait .05;

		currentWeapon = self getCurrentWeapon();
		self.newCamo = GetCamoInt(arguments[1]);
		self takeweapon(currentweapon);

		if (isSubStr(arguments[0], "akimbo"))
			self _giveWeapon(arguments[0], self.newCamo, true);
		else self _giveWeapon(arguments[0], self.newCamo, false);
		wait .05;

		self switchToWeapon(arguments[0]);

	}
}

GetCamoInt(tracker)
{
	switch (tracker)
	{
		case "desert":
			return 2;
		case "arctic":
			return 3;
		case "woodland":
			return 1;
		case "digital":
			return 4;
		case "urban":
			return 5;
		case "red":
			return 6;
		case "blue":
			return 7;
		case "fall":
			return 8;
		default:
			return 0;
	}
}

GetCamoName(tracker)
{
	switch (tracker)
	{
		case "desert":
			return "_desert";
		case "arctic":
			return "_arctic";
		case "woodland":
			return "_woodland";
		case "digital":
			return "_digital";
		case "urban":
			return "_red_urban";
		case "red":
			return "_red_tiger";
		case "blue":
			return "_blue_tiger";
		case "fall":
			return "_orange_fall";
		default:
			return "";
	}
}


SecondaryCamo()
{
	sec = self.secondaryWeapon;
	self takeweapon(sec);
	wait .1;

	if (isSubStr(sec, "akimbo"))
		self _giveWeapon(sec, self.loadoutPrimaryCamo, true);
	else self _giveWeapon(sec, self.loadoutPrimaryCamo, false);
	wait .1;
}


PointsPerKill()
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


GibeKillStreak()
{
	self endon("disconnect");
	setDvarIfUninitialized("mvm_killstreak", "Give ^3Killstreak");
	self notifyOnPlayerCommand("mvm_killstreak", "mvm_killstreak");
	for (;;)
	{
		self waittill("mvm_killstreak");
		self maps\ mp\ killstreaks\ _killstreaks::giveKillstreak(getDvar("mvm_killstreak"), false);
	}
}


/*================================== OTHER ====================================================
=============================================================================================*/


Noclip()
{
	self endon("disconnect");
	self endon("death");
	self endon("killnoclip");
	setDvarIfUninitialized("noclip2", "");
	self notifyOnPlayerCommand("noclip2", "noclip2");
	maps\ mp\ gametypes\ _spectating::setSpectatePermissions();
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

SaveSpawn()
{
	self.spawn_origin = self.origin;
	self.spawn_angles = self getPlayerAngles();
}

BotPrestige()
{
	self setPlayerData("prestige", 9);
	self setPlayerData("experience", 0);
}

clone()
{
	self endon("disconnect");
	self endon("death");
	setDvarIfUninitialized("clone", "*none* ^8- ^3Spawns a clone of yourself");
	self notifyOnplayerCommand("clone", "clone");
	for (;;)
	{
		self waittill("clone");
		self PrepareInHandModel();
		wait .1;
		self ClonePlayer(1);
		wait .1;
		self.weaptoattach delete();
	}
}

clearBodies()
{
	self endon("disconnect");
	self endon("death");
	setDvarIfUninitialized("clearb", "*none* ^8- ^3Clears all bodies");
	self notifyOnplayerCommand("clearb", "clearb");
	for (;;)
	{
		self waittill("clearb");
		self thread savespawn();
		self setOrigin((-9999, -9999, 9999));
		for (i = 0; i < 15; i++)
		{
			self ClonePlayer(1);
			wait .1;
		}
		self thread loadpos();
	}
}

PrepareInHandModel()
{
	currentWeapon = self getCurrentWeapon();


	if (isDefined(self.weaptoattach))
	{
		self.weaptoattach delete();
	}

	self.weaptoattach = getWeaponModel(currentWeapon, self.loadoutPrimaryCamo);
	self attach(self.weaptoattach, "j_gun", true);
	hideTagList = GetWeaponHideTags(currentWeapon);

	for (i = 0; i < hideTagList.size; i++)
	{
		self HidePart(hideTagList[i], self.weaptoattach);
	}
	return self.weaptoattach;
}

loadPos()
{
	self freezecontrols(true);
	wait .05;
	self setPlayerAngles(self.spawn_angles);
	self setOrigin(self.spawn_origin);
	wait .05;
	self freezecontrols(false);
}


WelcomeMsg()
{
	self endon("disconnect");
	{
		if (!isDefined(self.donefirst) && self.pers["isBot"] == false)
		{
			wait 6; // Wait the end of the team popup
			self thread teamPlayerCardSplash("callout_capturedhq", self, self.pers["team"]);
			self IPrintLn("Welcome to ^3IW4MVM ^7MW2 cinematic mod");
			self IPrintLn("Type ^3/about ^7for more ^3infos");
			self.donefirst = 1;
		}
	}
}

About()
{
	self endon("disconnect");
	self endon("death");

	setDvarIfUninitialized("about", "About the mod...");
	self notifyOnplayerCommand("about", "about");
	for (;;)
	{
		self waittill("about");

		self IPrintLnBold("Sass' ^3MW2 Movie ^7Mod");
		wait 1.5;
		self IPrintLnBold("Version : #280 - ^3Dirty");
		wait 1.5;
		self IPrintLnBold("Current ^3Addon ^7: " + level.patch);
		wait 1.5;
		self IPrintLnBold("^3Thanks ^7for downloading !");
		self IPrintLn("^1Thanks to / Credits :");
		self IPrintLn("- case, ozzie and jayy for their coolness");
		self IPrintLn("- luckyy & CoDTVMM team for base help");
		self IPrintLn("- Lasko for the menus");
		self IPrintLn("- You and everybody who supported the project :D");
	}
}

Instaclass()
{
	self endon("disconnect");

	oldclass = self.pers["class"];
	for (;;)
	{
		if (self.pers["class"] != oldclass)
		{
			assert(isValidClass(self.class));
			self maps\ mp\ gametypes\ _class::setClass(self.class);
			self maps\ mp\ gametypes\ _class::giveloadout(self.team, self.class);
			oldclass = self.pers["class"];
			thread SecondaryCamo();
			self thread VerifyModel();
			self maps\ mp\ perks\ _perks::givePerk("specialty_falldamage");
			self maps\ mp\ perks\ _perks::givePerk("specialty_marathon");
		}
		wait 0.05;
	}
}