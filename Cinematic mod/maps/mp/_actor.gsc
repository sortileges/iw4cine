/*
 *	SASS' CINEMATIC MOD - Actors file (#304)
 */

#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_movie;
#include maps\mp\_misc;
#include _precache;


actor()
{
	level thread OnPlayerConnect();
	level thread PrepareGoProObject();
	
	level._effect[ "shot1" ] = loadfx( "muzzleflashes/ak47_flash_wv" );
	level._effect[ "shot2" ] = loadfx( "muzzleflashes/heavy" );
	level._effect[ "shotgun" ] = loadfx( "muzzleflashes/shotgunflash_view" );
	level._effect[ "headshot" ] = loadfx( "impacts/flesh_hit_head_fatal_exit" );
	level._effect[ "blood" ] = loadfx("impacts/flesh_hit_body_fatal_exit" );
	level._effect[ "flash" ] = loadfx( "explosions/flashbang" );
	
	level.actorCount = 1;
	setDvarIfUninitialized("ui_showActorNames", "1");
}

OnPlayerConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		player thread OnPlayerSpawn();
	}
}


OnPlayerSpawn()
{
	self endon("disconnect");
	for (;;)
	{
		self waittill("spawned_player");

		self thread ActorSpawn();
		self thread ActorModel();
		self thread ActorHP();
		self thread ActorDelete();
		self thread ActorEquip();
		self thread ActorPlayFX();
		self thread ActorNormWalk();
		self thread ActorNormWalkActorBack();
		self thread ActorNormWalkAutoStop();
		self thread ActorNormAnim();
		self thread ActorDeathFX();
		self thread ActorDeathAnim();
		self thread ActorTeleport();
		self thread ActorBack();
		self thread ActorSetPath();
		self thread ActorDoPath();
		self thread ActorDeletePath();
		self thread ActorGoPro();
		self thread ActorRename();
		
		if (self.pers["isBot"] == false) {
			self thread ActorShowNames();
			self thread ActorOverheadText();
		}
	}
}

ActorSpawn()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_spawn", "Spawn an actor - ^9[body head]");
	self notifyOnPlayerCommand("mvm_actor_spawn", "mvm_actor_spawn");

	for(;;)
	{
		self waittill("mvm_actor_spawn");

		start = self getTagOrigin("tag_eye");
		end = anglestoforward(self getPlayerAngles()) * 1000000;
		actorpos = BulletTrace(start, end, true, self)["position"];

		argumentstring = getDvar("mvm_actor_spawn");
		arguments = StrTok(argumentstring, " ,");

		if (isDefined(arguments[2]))
			spawnAnim = arguments[2];
		else spawnAnim = "pb_stand_alert";

		level.actor[level.actorCount] = spawn("script_model", actorpos);
		level.actor[level.actorCount].angles = self.angles + (0, 180, 0);
		level.actor[level.actorCount] EnableLinkTo();
		level.actor[level.actorCount] setModel(arguments[0]);
		level.actor[level.actorCount] scriptModelPlayAnim(spawnAnim);
		level.actor[level.actorCount].name = "actor" + level.actorCount;

		level.actor[level.actorCount].oldorg = level.actor[level.actorCount].origin;
		level.actor[level.actorCount].oldang = level.actor[level.actorCount].angles;

		level.actor[level.actorCount].head = spawn("script_model", level.actor[level.actorCount] getTagOrigin("j_spine4"));
		level.actor[level.actorCount].head setModel(arguments[1]);
		level.actor[level.actorCount].head.angles = level.actor[level.actorCount].angles + (270, 0, 270);
		level.actor[level.actorCount].head linkto(level.actor[level.actorCount], "j_spine4");
		level.actor[level.actorCount].head scriptModelPlayAnim(spawnAnim);

		self iPrintLn("[" + level.actor[level.actorCount].name + "] : Spawned !");

		for (f = 1; f < 13; f++)
		{
			level.actor[level.actorCount].nodeorg[f] = 0;
			level.actor[level.actorCount].nodeang[f] = 0;
			level.actor[level.actorCount].nodeobj[f] = undefined;
			wait 0.05;
		}
		level.actor[level.actorCount] thread PathDebug();
		level.actor[level.actorCount].nodecount = 0;

		level.actor[level.actorCount].hitbox = spawn("script_model", level.actor[level.actorCount].origin + (0, 0, 30));
		level.actor[level.actorCount].hitbox setModel("com_plasticcase_enemy");
		level.actor[level.actorCount].hitbox Solid();
		level.actor[level.actorCount].hitbox.angles = (90, 0, 0);
		level.actor[level.actorCount].hitbox hide();
		level.actor[level.actorCount].hitbox.name = "actor" + level.actorCount; //c.f ActorShowNames()
		level.actor[level.actorCount].hitbox setCanDamage(1);
		level.actor[level.actorCount].hitbox.health = 120; //default value
		level.actor[level.actorCount].hitbox.savedhealth = 120; //same
		level.actor[level.actorCount].hitbox.isDead = false;
		level.actor[level.actorCount].hitbox linkto(level.actor[level.actorCount]);
		level.actor[level.actorCount].hitbox thread ActorHandleDamage(level.actor[level.actorCount].hitbox, level.actor[level.actorCount]);

		level.actor[level.actorCount].deathanim = "pb_stand_death_chest_blowback";
		level.actor[level.actorCount].assignedanim = spawnAnim;
		level.actorCount++;
	}
}

GetActor(argument)
{
	if (argument == "all")
	{
		return level.actor;
	}
	foreach(actor in level.actor)
	{
		if(argument == "look")
		{
			vec = anglestoforward(self getPlayerAngles());
			entity = BulletTrace( self getTagOrigin("tag_eye"), self getTagOrigin("tag_eye") + (vec[0] * 500, vec[1] * 500, vec[2] * 500), 0, self )[ "entity" ];
			if(isDefined(entity.model) && entity.name == actor.name)
			{
				ret = [];
				ret[0] = actor;
				return ret;
			}
		}
		else if (argument == actor.name)
		{
			ret = [];
			ret[0] = actor;
			return ret;
		}
	}
	return undefined;
}

ActorModel()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_model", "Change model - ^9[actor body head]");
	self notifyOnPlayerCommand("mvm_actor_model", "mvm_actor_model");

	for (;;)
	{
		self waittill("mvm_actor_model");

		argumentstring = getDvar("mvm_actor_model");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				if (arguments[1] == "head")
				{
					actor.head setModel(arguments[2]);
				}
				else if (arguments[1] == "body")
				{
					actor setModel(arguments[2]);
				}
				else 
				{
					actor setModel(arguments[1]);
					actor.head setModel(arguments[2]);
				}		

				self iPrintLn("[" + actor.name + "] : Updated model(s)");
			}
		}
	}
}


ActorHP()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_health", "Health amount - ^9[actor health]");
	self notifyOnPlayerCommand("mvm_actor_health", "mvm_actor_health");

	for (;;)
	{
		self waittill("mvm_actor_health");

		argumentstring = getDvar("mvm_actor_health");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				actor.hitbox.savedhealth = int(arguments[1]);
				actor.hitbox.health = actor.hitbox.savedhealth;
				self iPrintLn("[" + actor.name + "] : Health set to ^8" + actor.hitbox.savedhealth );
			}
		}
	}
}



ActorDelete()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_delete", "Delete an actor - ^9[actor]");
	self notifyOnPlayerCommand("mvm_actor_delete", "mvm_actor_delete");

	for (;;)
	{
		self waittill("mvm_actor_delete");
		actors = GetActor(getDvar("mvm_actor_delete"));
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				actor Delete();
				actor.head Delete();
				actor.hitbox Delete();
				foreach (wep in actor.equ)
				{
					if(isDefined(wep))
					{
						wep Delete();
					}
				}
				actor.equ Delete();
				self iPrintLn("[" + actor.name + "] : Deleted!");
			}
		}
	}
}

ActorNormAnim()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_anim", "Actor base animation - ^9[actor anim]");
	self notifyOnPlayerCommand("mvm_actor_anim", "mvm_actor_anim");

	for (;;)
	{
		self waittill("mvm_actor_anim");

		argumentstring = getDvar("mvm_actor_anim");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				actor scriptModelPlayAnim(arguments[1]);
				actor.head scriptModelPlayAnim(arguments[1]);
				actor.assignedanim = arguments[1];
				self iPrintLn("[" + actor.name + "] : Base anim set to ^8" + actor.assignedanim );
			}
		}
	}
}


ActorPlayFX()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_fx", "Play FX on tag - ^9[actor tag effect]");
	self notifyOnPlayerCommand("mvm_actor_fx", "mvm_actor_fx");

	for (;;)
	{
		self waittill("mvm_actor_fx");

		argumentstring = getDvar("mvm_actor_fx");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				playFxOnTag( level._effect[arguments[2]], actor, arguments[1] );
			}
		}
	}
}

ActorDeathFX()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_death_fx", "Play FX on tag - ^9[actor tag effect]");
	self notifyOnPlayerCommand("mvm_actor_death_fx", "mvm_actor_death_fx");

	for (;;)
	{
		self waittill("mvm_actor_death_fx");

		argumentstring = getDvar("mvm_actor_death_fx");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				actor.death_fx_bone = arguments[1];
				actor.death_fx = arguments[2];
			}
		}
	}
}


ActorDeathAnim()
{
	self endon("death");
	self endon("disconnect");
	self endon("done");

	setDvarIfUninitialized("mvm_actor_death", "Actor death animation - ^9[actor anim]");
	self notifyOnPlayerCommand("mvm_actor_death", "mvm_actor_death");

	for (;;)
	{
		self waittill("mvm_actor_death");

		argumentstring = getDvar("mvm_actor_death");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				actor.deathanim = arguments[1];
				self iPrintLn("[" + actor.name + "] : Death anim set to ^8" + actor.deathanim );
			}
		}
	}
}

ActorEquip()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_weapon", "Actor weapon - ^9[actor tag weapon camo]");
	self notifyOnPlayerCommand("mvm_actor_weapon", "mvm_actor_weapon");

	for (;;)
	{
		self waittill("mvm_actor_weapon");

		argumentstring = getDvar("mvm_actor_weapon");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				equ_angles = actor getTagAngles(arguments[1]);
				equ_origin = actor getTagOrigin(arguments[1]);
				actorWeaponHideTagList = GetWeaponHideTags(arguments[2]);

				if (isDefined(actor.equ[arguments[1]]))
				{
					actor.equ[arguments[1]] delete();
				}
					

				if ( isSubStr(arguments[2], "_mp") && !(maps\mp\gametypes\_class::isValidWeapon(arguments[2])) ) 
				{
					self thread ActorEquip();
					return self iPrintLn( "[^1ERROR^7] ^8" + arguments[2] + " ^7isn't a valid weapon");
				}

				weaponModel = checkIfWeirdWeapon(getweaponmodel(arguments[2]) , arguments[3]);
				weaponCamo = checkIfCamoAvailable(arguments[2] , arguments[3]);

				actor.equ[arguments[1]] = spawn("script_model", actor GetTagOrigin(arguments[1]));
				actor.equ[arguments[1]] linkTo(actor, arguments[1], (0, 0, 0), (0, 0, 0));

				if (isSubStr(arguments[2], "_mp")) 
				{
					actor.equ[arguments[1]] setModel( weaponModel + weaponCamo);
					for (i = 0; i < actorWeaponHideTagList.size; i++) {
						actor.equ[arguments[1]] HidePart(actorWeaponHideTagList[i], weaponModel + weaponCamo);
					}
					self iPrintLn("[" + actor.name + "] : ^8" + weaponModel + weaponCamo + " ^7attached to ^8" + arguments[1] );
				}
				else if (arguments[2] != "delete") 
				{
					actor.equ[arguments[1]] setModel(arguments[2]);
					self iPrintLn("[" + actor.name + "] : ^8" + arguments[2] + " ^7attached to ^8" + arguments[1] );
				}
			}
		}
	}
}

ActorNormWalkActorBack()
{
	self endon("death");
	self endon("disconnect");
	setDvarIfUninitialized("mvm_actor_walk_actorback", "Toggle walk on actorback - ^9[actor]");
	self notifyOnPlayerCommand("mvm_actor_walk_actorback", "mvm_actor_walk_actorback");

	for (;;)
	{
		self waittill("mvm_actor_walk_actorback");
		actors = GetActor(getDvar("mvm_actor_walk_actorback"));
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				if (!isDefined(actor.walk_actorback) || actor.walk_actorback == false)
				{
					self iPrintLn("mvm_actor_walk_actorback - " + actor.name + " - ^2ON");
					actor.walk_actorback = true;
				}
				else if (actor.walk_actorback == true)
				{
					self iPrintLn("mvm_actor_walk_actorback - " + actor.name + " - ^1OFF");
					actor.walk_actorback = false;
				}
			}
		}
	}
}

ActorNormWalk()
{
	self endon("death");
	self endon("disconnect");
	self endon("done");

	setDvarIfUninitialized("mvm_actor_walk", "Walk to dir - ^9[actor time dir]");
	self notifyOnPlayerCommand("mvm_actor_walk", "mvm_actor_walk");

	for (;;)
	{
		self waittill("mvm_actor_walk");

		argumentstring = getDvar("mvm_actor_walk");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				actor.walk_speed = float(arguments[1]);
				actor.walk_direction = arguments[2];
				MakeActorNormWalk(actor);
			}
		}
	}
}

MakeActorNormWalk(actor)
{
	if(!isDefined(actor.walk_speed) || !isDefined(actor.walk_direction)) return;
	time = actor.walk_speed * 100;
	target = [];
	distance = 600 * 100;
	if (actor.walk_direction == "forward")
	{
		vec = anglestoforward(actor.angles);
		target = (vec[0] * distance, vec[1] * distance, vec[2] * distance);
	}
	else if (actor.walk_direction == "backward")
	{
		vec = anglestoforward(actor.angles);
		target = (vec[0] * (distance * -1), vec[1] * (distance * -1), vec[2] * (distance * -1));
	}
	else if (actor.walk_direction == "right")
	{
		vec = anglestoright(actor.angles);
		target = (vec[0] * distance, vec[1] * distance, vec[2] * distance);
	}
	else if (actor.walk_direction == "left")
	{
		vec = anglestoright(actor.angles);
		target = (vec[0] * (distance * -1), vec[1] * (distance * -1), vec[2] * (distance * -1));
	}
	else if (actor.walk_direction == "up")
	{
		vec = anglesToUp(actor.angles);
		target = (vec[0] * distance, vec[1] * distance, vec[2] * distance);
	}
	else if (actor.walk_direction == "down")
	{
		vec = anglesToUp(actor.angles);
		target = (vec[0] * (distance * -1), vec[1] * (distance * -1), vec[2] * (distance * -1));
	}
	else if (actor.walk_direction == "forwardup")
	{
		vec = (anglestoforward(actor.angles) + anglesToUp(actor.angles));
		target = (vec[0] * distance, vec[1] * distance, vec[2] * distance);
	}
	else if (actor.walk_direction == "forwarddown")
	{
		vec = (anglestoforward(actor.angles) - anglesToUp(actor.angles));
		target = (vec[0] * distance, vec[1] * distance, vec[2] * distance);
	}
	else if (actor.walk_direction == "backwardup")
	{
	vec = (anglestoforward(actor.angles) - anglesToUp(actor.angles));
	target = (vec[0] * (distance * -1), vec[1] * (distance * -1), vec[2] * (distance * -1));
	}
	else if (actor.walk_direction == "backwarddown")
	{
		vec = (anglestoforward(actor.angles) + anglesToUp(actor.angles));
		target = (vec[0] * (distance * -1), vec[1] * (distance * -1), vec[2] * (distance * -1));
	}
	actor MoveTo(actor.origin + target, time, 0, 0);
}

ActorNormWalkAutoStop()
{
	self endon("death");
	self endon("disconnect");
	setDvarIfUninitialized("mvm_actor_walk_autostop", "Toggle stop actor on death - ^9[actor]");

	self notifyOnPlayerCommand("mvm_actor_walk_autostop", "mvm_actor_walk_autostop");
	for (;;)
	{
		self waittill("mvm_actor_walk_autostop");
		actors = GetActor(getDvar("mvm_actor_walk_actorback"));
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				if (!isDefined(actor.walk_autostop) || actor.walk_autostop == false)
				{
					self iPrintLn("mvm_actor_walk_autostop - " + actor.name + " - ^2ON");
					actor.walk_autostop = true;
				}
				else if ( actor.walk_autostop == true)
				{
					self iPrintLn("mvm_actor_walk_autostop - " + actor.name + " - ^1OFF");
					actor.walk_autostop = false;
				}
			}
		}
		
	}
}


ActorTeleport()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_move", "Teleport actor to you - ^9[actor]");
	self notifyOnPlayerCommand("mvm_actor_move", "mvm_actor_move");

	for (;;)
	{
		self waittill("mvm_actor_move");
		actors = GetActor(getDvar("mvm_actor_move"));
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				actor MoveTo(self.origin, 0.1, 0, 0);
				actor RotateTo(self.angles, 0.1, 0, 0);
				actor.oldorg = self.origin;
				actor.oldang = self.angles;
			}
		}
	}
}


ActorBack()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("actorback", " ");
	self notifyOnPlayerCommand("actorback", "actorback");

	for (;;)
	{
		self waittill("actorback");

		foreach(actor in level.actor)
		{
			actor.hitbox.health = actor.hitbox.savedhealth;
			actor MoveTo(actor.oldorg, 0.1, 0, 0);
			actor RotateTo(actor.oldang, 0.1, 0, 0);
			actor scriptModelPlayAnim(actor.assignedanim);
			actor.head scriptModelPlayAnim(actor.assignedanim);

			if (actor.hitbox.isDead == true)
			{
				actor.hitbox.isDead = false;
				actor.hitbox thread ActorHandleDamage(actor.hitbox, actor);
			}
		}
		wait 0.2;
		foreach(actor in level.actor)
		{
			if(isDefined(actor.walk_actorback) && actor.walk_actorback == true && isDefined(actor.walk_speed) && isDefined(actor.walk_direction))
			{
				MakeActorNormWalk(actor);
			}
		}
		self iPrintLn("All actors reset!");
	}
}

ActorGoPro()
{
	self endon("disconnect");
	self endon("death");

	setDvarIfUninitialized("mvm_actor_gopro", "GoPro - ^9[action/actor tag x y z r p y]");
	self notifyOnPlayerCommand("mvm_actor_gopro", "mvm_actor_gopro");

	for (;;)
	{
		self waittill("mvm_actor_gopro");

		argumentstring = getDvar("mvm_actor_gopro");
		arguments = StrTok(argumentstring, " ,");

		if (arguments[0] == "delete")
		{
			level.gopro unlink();
			level.gopro.linked = 0;
			level.gopro MoveTo((9999, 9999, 9999), .1);
		}
		else if (arguments[0] == "on")
		{
			self CameraLinkTo(level.gopro, "tag_origin");
			setDvar("cg_drawgun", 0);
			setDvar("cg_draw2d", 0);
			self allowSpectateTeam("freelook", true);
			self.sessionstate = "spectator";
		}
		else if (arguments[0] == "off")
		{
			self CameraUnlink();
			setDvar("cg_drawgun", 1);
			setDvar("cg_draw2d", 1);
			self.sessionstate = "playing";
			self allowSpectateTeam("freelook", false);
		}
		else
		{
			actors = GetActor(arguments[0]);
			if(isDefined(actors))
			{
				foreach (actor in actors)
				{
					if (level.gopro.linked == 1)
					{
						level.gopro unlink();
						level.gopro.linked = 0;
					}
					level.gopro.origin = actor GetTagOrigin(arguments[1]);
					level.gopro.angles = actor GetTagAngles(arguments[1]);
					wait 0.05;
					level.gopro linkTo(actor, arguments[1], (int(arguments[2]), int(arguments[3]), int(arguments[4])), (int(arguments[5]), int(arguments[6]), int(arguments[7])));
					level.gopro.linked = 1;
				}
			}
		}
	}
}


ActorSetPath()
{
	self endon("disconnect");
	self endon("death");

	setDvarIfUninitialized("mvm_actor_path_save", "Save node for bezier - ^9[actor node]");
	self notifyOnPlayerCommand("mvm_actor_path_save", "mvm_actor_path_save");

	for (;;)
	{
		self waittill("mvm_actor_path_save");

		argumentstring = getDvar("mvm_actor_path_save");
		arguments = StrTok(argumentstring, " ,");

		if (int(arguments[1]) > 13)
		{
			iPrintLn("[^1ERROR^7] : Can only save node #1 to #13");
		}
		else
		{
			actors = GetActor(arguments[0]);
			if(isDefined(actors))
			{
				foreach (actor in actors)
				{
					f = int(arguments[1]);
					actor.nodeorg[f] = self.origin;
					actor.nodeang[f] = self.angles;
					if (actor.nodecount <= f) actor.nodecount = f;


					if (isDefined(level.actorpath["node"][f])) level.actorpath["node"][f] delete();
					level.actorpath["node"][f] = spawn("script_model", self.origin);
					level.actorpath["node"][f].angles = self.angles;

					iPrintLn("[" + actor.name + "] : Node #" + arguments[1] + " saved ");
					self thread DeleteActorPath();
					self thread UpdateActorPath(actor);
				}
			}
		}
	}
}

ActorDeletePath()
{
	self endon("death");
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_path_del", "Delete node for bezier - ^9[actor node]");
	self notifyOnPlayerCommand("mvm_actor_path_del", "mvm_actor_path_del");

	for (;;)
	{
		self waittill("mvm_actor_path_del");

		argumentstring = getDvar("mvm_actor_path_del");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				d = arguments[1];
				f = int(arguments[1]);

				self DeleteActorPath();

				if (actor.nodecount == 0)
					self IPrintLn("[" + actor.name + "] : Nothing to delete");
				else if (d == "all" || f == 1)
				{
					for (i = 0; i <= actor.nodecount; i++)
					{
							actor.nodeorg[i] = undefined;
							actor.nodeang[i] = undefined;
					}
					self iPrintLn("[" + actor.name + "] : All nodes deleted!");
					actor.nodecount = 0;
				}
				else if (f > 0)
				{
					for (i = f; i <= actor.nodecount; i++)
					{
						actor.nodeorg[i] = undefined;
						actor.nodeang[i] = undefined;
					}
					actor.nodecount = f - 1;
					self UpdateActorPath(actor);
					self iPrintLn("[" + actor.name + "] : Deleted node #" + f + " and above");
				}
				else self IPrintLn("[^3WARNING^7] : Looks like you did something weird");
			}
		}
		wait .1;
	}
}

DeleteActorPath()
{
	foreach(actorpath in level.actorpath)
	{
		actorpath["path"] delete();
		actorpath["node"] delete();
	}
}

HideActorPath()
{
	foreach(actorpath in level.actorpath)
	{
		actorpath["path"] hide();
		actorpath["node"] hide();
	}
}

ShowActorPath()
{
	foreach(actorpath in level.actorpath)
	{
		actorpath["path"] show();
		actorpath["node"] show();
	}
}

UpdateActorPath(actor)
{
	level.actorpath["path"] = [];
	level.actorpathtotal = 0;

	level.actorpathsteps = (2000 * actor.nodecount / 400);
	for (j = 0; j < (level.actorpathsteps); j++)
	{
		t = j / (level.actorpathsteps - 1);
		vect[0] = 0;
		vect[1] = 0;
		vect[2] = 0;
		angle[0] = 0;
		angle[1] = 0;
		angle[2] = 0;

		for (i = 1; i <= actor.nodecount; i++)
		{
			for (z = 0; z < 3; z++)
			{
				vect[z] += float(koeff(i - 1, actor.nodecount - 1) * pow((1 - t), actor.nodecount - i) * pow(t, i - 1) * actor.nodeorg[i][z]);
				angle[z] += float(koeff(i - 1, actor.nodecount - 1) * pow((1 - t), actor.nodecount - i) * pow(t, i - 1) * actor.nodeang[i][z]);
			}
		}
		level.actorpath[level.actorpathtotal]["path"] = spawn("script_model", (vect[0], vect[1], vect[2]));
		level.actorpath[level.actorpathtotal]["path"] setModel("projectile_semtex_grenade_bombsquad");
		level.actorpath[level.actorpathtotal]["path"].angles = (angle[0], angle[1], angle[2]);
		level.actorpathtotal++;
	}
}

ActorDoPath()
{
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_path_walk", "Actor follows bezier - ^9[actor time]");
	self notifyOnPlayerCommand("mvm_actor_path_walk", "mvm_actor_path_walk");

	for (;;)
	{
		self waittill("mvm_actor_path_walk");

		argumentstring = getDvar("mvm_actor_path_walk");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors))
		{
			foreach (actor in actors)
			{
				if (actor.nodecount == 2)
				{
					actor SetOrigin(self.actororgstart);
					actor SetPlayerAngles(self.actorangstart);
					wait .1;
					HideActorPath();
					actor MoveTo(actor.nodeorg[1], 0.1, 0, 0);
					actor RotateTo(actor.nodeang[1], 0.1, 0, 0);
					wait 2;
					actor MoveTo(actor.nodeorg[2], stringToFloat(arguments[1]), 0, 0);
					actor RotateTo(actor.nodeang[2], stringToFloat(arguments[1]), 0, 0);
					wait stringToFloat(arguments[1]);
					ShowActorPath();
				}
				else
				{
					actor SetOrigin(self.actororgstart);
					actor SetPlayerAngles(self.actorangstart);
					wait .1;
					HideActorPath();
					actor MoveTo(actor.nodeorg[1], 0.1, 0, 0);
					actor RotateTo(actor.nodeang[1], 0.1, 0, 0);
					actor PreparePath(actor);
					wait 2;
					actor ActorDoWalk(actor, int(arguments[1]));
					ShowActorPath();
				}
			}
		}
	}
}

ActorRename()
{
	self endon("disconnect");

	setDvarIfUninitialized("mvm_actor_rename", "Change actor name - ^9[actor newname]");
	self notifyOnPlayerCommand("mvm_actor_rename", "mvm_actor_rename");

	for (;;)
	{
		self waittill("mvm_actor_rename");

		argumentstring = getDvar("mvm_actor_rename");
		arguments = StrTok(argumentstring, " ,");
		actors = GetActor(arguments[0]);
		if(isDefined(actors) && arguments[1] != "look") // make sure it's not possible to name an actor "look"
		{
			foreach (actor in actors)
			{
				self iPrintLn("[" + actor.name + "] : Renamed to '" + arguments[1] + "'");
				actor.name = arguments[1];
				actor.hitbox.name = arguments[1];
			}
		}
	}
}

PathDebug()
{
	if (!isDefined(self.actororgstart))
	{
		self.actororgstart = self GetOrigin();
		self.actorangstart = (0, 360, 0);
		level.cam["poscount"] = 0;
	}
}

ActorHandleDamage(crate, actor)
{
	while (self.health > 0)
	{
		self waittill("damage", amount, attacker, dir, point, type);
		level.actorAttacker = attacker;
		attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("standard");

		if (isDefined(attacker) && isPlayer(attacker) && attacker != self.owner)
			self.health -= amount;
	}
	if(isDefined(actor.walk_autostop) && actor.walk_autostop == true)
	{
		actor MoveTo(actor.origin, 0.1, 0, 0);
	}

	actor.hitbox.isDead = true;
	actor scriptModelPlayAnim(actor.deathanim);
	actor.head scriptModelPlayAnim(actor.deathanim);
	actor PlaySound( "generic_death_american_" + RandomIntRange(1, 8) );
	if(isDefined(actor.death_fx_bone) && isDefined(actor.death_fx))
	{
		playFx(level._effect[actor.death_fx], actor getTagOrigin(actor.death_fx_bone));
	}
	else
	{
		playFx(level._effect["blood"], actor getTagOrigin("j_spine4"));
	}

	wpnName = StrTok(level.actorAttacker getCurrentWeapon(), "_"); // Won't work with equipment kills but oh well
	level.actorAttacker iPrintLn( "^8" + level.actorAttacker.name + " ^7[" + wpnName[0] + "] ^9" + actor.name);
	level.actorAttacker maps\mp\gametypes\_rank::scorePopup( ( level.scoreInfo["kill"]["value"] ) , 0);

	
}

PrepareGoProObject()
{
	level.gopro = spawn("script_model", (9999, 9999, 9999));
	level.gopro setModel("tag_origin");
	level.gopro.origin = self getorigin();
	level.gopro.angles = self getplayerangles();
	level.gopro.linked = 0;
	level.gopro enablelinkto();
	wait .1;
	level.gopro.object = spawn("script_model", (9999, 9999, 9999));
	level.gopro.object setModel("projectile_rpg7");
	level.gopro.object.origin = level.gopro.origin;
	level.gopro.object.angles = (level.gopro.angles - (15, 0, 0));
	wait .1;
	level.gopro.object linkTo(level.gopro, "tag_origin");
}

ActorShowNames()
{
	self endon("death");
	self endon("disconnect");
	
	for(;;)
	{
		actors = GetActor("look");
		if( isDefined(actors) && getDvar("ui_showActorNames") == "1")
		{
			foreach (actor in actors)
			{
				level.actorNameDisplay setText(actor.name);
			}
		}
		else level.actorNameDisplay setText(" ");
		wait .1;
	}
}

ActorOverheadText()
{
	if (isDefined(level.actorNameDisplay))
		level.actorNameDisplay destroy();

	level.actorNameDisplay = newClientHudElem(self);
	level.actorNameDisplay.horzAlign = "center";
	level.actorNameDisplay.vertAlign = "middle";
	level.actorNameDisplay.x = 20;
	level.actorNameDisplay.y = -20;
	level.actorNameDisplay.color = (0.6, 1, 0.6);
	level.actorNameDisplay.alpha = 1;
	level.actorNameDisplay.font = "Objective";
	level.actorNameDisplay.fontscale = 1.2;
	level.actorNameDisplay.hideWhenInMenu = true;
	level.actorNameDisplay setText(" ");
}

PreparePath(actor)
{
	level.alldist = 0;
	for (k = 1; k < actor.nodecount; k++)
	{
		x = actor.nodeang[k][1];
		y = actor.nodeang[k + 1][1];

		if (y - x >= 180)
		{
			actor.nodeang[k] += (0, 360, 0);
		}

		else if (y - x <= -180)
		{
			actor.nodeang[k + 1] += (0, 360, 0);
		}

		level.partdist[k] = distance(actor.nodeorg[k], actor.nodeorg[k + 1]);
		level.angledist[k] = distance(actor.nodeang[k], actor.nodeang[k + 1]);
		level.alldist += level.partdist[k];
		level.alldist += level.angledist[k];
	}
}

ActorDoWalk(actor, speed)
{
	dist = level.alldist;
	level.multiplier = getDvarInt("cam_fps") / 100;

	for (j = 0; j <= dist * 10 * level.multiplier / speed; j++)
	{
		t = (j * speed / (dist * 10 * level.multiplier));
		vect[0] = 0;
		vect[1] = 0;
		vect[2] = 0;
		angle[0] = 0;
		angle[1] = 0;
		angle[2] = 0;

		for (i = 1; i <= actor.nodecount; i++)
		{
			for (z = 0; z < 3; z++)
			{
				vect[z] += float(koeff(i - 1, actor.nodecount - 1) * pow((1 - t), actor.nodecount - i) * pow(t, i - 1) * actor.nodeorg[i][z]);
				angle[z] += float(koeff(i - 1, actor.nodecount - 1) * pow((1 - t), actor.nodecount - i) * pow(t, i - 1) * actor.nodeang[i][z]);
			}
		}
		actor MoveTo((vect[0], vect[1], vect[2]), .1, 0, 0);
		actor RotateTo((angle[0], angle[1], angle[2]), .1, 0, 0);
		wait .01;
	}
	wait 0.1;
}

float(var)
{
	setDvar("temp", var);
	return getDvarfloat("temp");
}

koeff(x, y)
{
	return (fact(y) / (fact(x) * fact(y - x)));
}

fact(x)
{
	c = 1;
	if (x == 0) return 1;
	for (i = 1; i <= x; i++)
		c = c * i;
	return c;
}

pow(a, b)
{
	x = 1;
	if (b != 0)
	{
		for (i = 1; i <= b; i++)
			x = x * a;
	}
	return x;
}
