/*-----------------------------------------------------------------------------
 * IW4MVM : Cinematic mod --- Actors scripts file
 * Mod current version : 214
 *-----------------------------------------------------------------------------
 * File Version   : 2.03
 * Created on     : 17-01-2017
 * Authors        : Civil, ozzie, Case
 *----------------------------------------------------------------------------*/

#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_movie;
#using_animtree( "destructibles" );
#using_animtree( "multiplayer" );

actor()
{
        setDvarIfUninitialized( "arg_bodyname", "" );
        setDvarIfUninitialized( "arg_headname", "" );
        setDvarIfUninitialized( "arg_weapname", "" );
		setDvarIfUninitialized( "arg_tagname", "" );
		setDvarIfUninitialized( "arg_pathtime", "" );
        setDvarIfUninitialized( "arg_animname", "" );
		setDvarIfUninitialized( "arg_danimname", "" );
		setDvarIfUninitialized( "arg_propname", "" );
		setDvarIfUninitialized( "arg_direction", "" );
		setDvarIfUninitialized( "arg_actorhp", "" );
        setDvarIfUninitialized( "arg_fx", "" );
		setDvarIfUninitialized( "arg_speede", "" );
		setDvarIfUninitialized( "mvm_actor_spawn", "body head - ^3Spawns actor" );
		setDvarIfUninitialized( "mvm_actor_anim", "anim - ^3Sets actor animation" );
		setDvarIfUninitialized( "mvm_actor_weapon", "actor tag weapon camo - ^3Sets actor weapon" );
		setDvarIfUninitialized( "mvm_actor_walk", "actor time direction - ^3Makes the actor walk towards the given direction" );
		setDvarIfUninitialized( "mvm_actor_health", "actor health - ^3hanges actor's health amount" );
		setDvarIfUninitialized( "mvm_actor_move", "actor - ^3Teleports actor to your position" );
		setDvarIfUninitialized( "mvm_actor_delete", "actor - ^3Deletes actor" );
		setDvarIfUninitialized( "mvm_actor_death", "actor anim - ^3Sets actor death anim" );
		setDvarIfUninitialized( "actorback", " " );
		setDvarIfUninitialized( "actor_test", " " );

			
		// Precache thread
		// IMPORTANT : Put your own precache in the _precache.gsc file, and not this one
		thread _precache::precache();

		PrecacheMPAnim("pb_hold_idle"); // Default stand anim
		PrecacheMPAnim("pb_stand_death_chest_blowback"); // Default death anim
		level._effect["blood"] = loadfx("impacts/flesh_hit_body_fatal_exit");

		level thread OnPlayerConnect();
}


OnPlayerConnect()
{
    for(;;)
    {
        level waittill( "connected", player );   
		player thread OnPlayerSpawn();
    }
}


OnPlayerSpawn()
{
    self endon( "disconnect" );
    for(;;)
    {
		self waittill("spawned_player");
	
		thread SpawnActor();
		thread HPActor();
		thread DeleteActor();
		thread AnimActor();
		thread EquipActor();
		thread PathActor();
		thread DeathActor();
		thread MeeActor();
		thread ActorBack();
    }
}



SpawnActor()
{
    self endon( "death" );
    self endon( "disconnect" );

	actor = [];
	
    self notifyOnPlayerCommand( "mvm_actor_spawn", "mvm_actor_spawn" );
    
	for (i=1; i>=0; i++)
    {
        
        self waittill("mvm_actor_spawn");
		
		start = self getTagOrigin( "tag_eye" );
        end = anglestoforward(self getPlayerAngles()) * 1000000;
        actorpos = BulletTrace(start, end, true, self)["position"];
		
		argumentstring = getDvar( "mvm_actor_spawn", "body head - ^3Spawns actor" );
        arguments = StrTok(argumentstring, " ,");
        setDvar("arg_bodyname", arguments[0]);
        setDvar("arg_headname", arguments[1]);

		level.actor[i] = spawn( "script_model", actorpos);
		level.actor[i].angles = self.angles + (0,180,0);
		level.actor[i] EnableLinkTo();
		level.actor[i] Solid();
     	level.actor[i] setModel(getDvar("arg_bodyname", ""));
		level.actor[i] scriptModelPlayAnim("pb_hold_idle");
		level.actor[i].name = ("actor" + i);
		
		level.actor[i].oldorg = 0;
		level.actor[i].oldang = 0;
        level.actor[i].ismoving = 0;
		
		level.actor[i].head = spawn("script_model", level.actor[i] getTagOrigin( "j_spine4" ));
		level.actor[i].head setModel(getDvar("arg_headname", ""));
		level.actor[i].head.angles = level.actor[i].angles +(270,0,270);
		level.actor[i].head linkto(level.actor[i], "j_spine4");
		level.actor[i].head scriptModelPlayAnim("pb_hold_idle");
		
		level.actor[i].hitbox = spawn("script_model", level.actor[i].origin + (0,0,30) ); 
		level.actor[i].hitbox setModel("com_plasticcase_enemy");
		level.actor[i].hitbox Solid();
		level.actor[i].hitbox.angles = (90,0,0);
		level.actor[i].hitbox hide();
		level.actor[i].hitbox.name = "hitbox" + i;
		level.actor[i].hitbox setCanDamage(1);
		level.actor[i].hitbox.health = 120; //default value
		level.actor[i].hitbox.savedhealth = 120; //same
		level.actor[i].hitbox linkto( level.actor[i] );
		
		level.actor[i].deathanim = "pb_stand_death_chest_blowback";
		level.actor[i].assignedanim = "pb_hold_idle";
		
		level.actor[i].hitbox thread ActorHandleDamage( level.actor[i].hitbox, level.actor[i] );
		
		self iPrintLn(level.actor[i].name + "^2 spawned ^7: " + actorpos);
		
	}
}



ClampToGround()
{
	for (;;)
    {
		trace = physicsTrace(self.origin + (0,0,50), self.origin + (0,0,-40));
		if((trace[2] - (self.origin[2]-40.0)) > 0.0 && ((self.origin[2]+50.0) - trace[2]) > 0.0)
			self MoveTo(trace, 0.05);	
		waitframe();
	}
}



HPActor()
{
    self endon( "death" );
    self endon( "disconnect" );
	
    self notifyOnPlayerCommand( "mvm_actor_health", "mvm_actor_health" );
    
	for (;;)
    {
        self waittill("actor_health");
		
		argumentstring = getDvar( "mvm_actor_health", "Set the actor's health" );
        arguments = StrTok(argumentstring, " ,");
        setDvar("arg_actorname", arguments[0]);
        setDvar("arg_actorhp", arguments[1]);
		
		foreach( actor in level.actor ) 
        {
            if(actor.name == getDvar("arg_actorname", ""))
			{
				actor.hitbox.savedhealth = getDvarInt("arg_actorhp");
				actor.hitbox.health = actor.hitbox.savedhealth;
				self iPrintLnBold( "^2" + actor.name +"^7's health set to ^2" + actor.hitbox.savedhealth );
			}
        }
	}
}

ActorHandleDamage( crate, actor )
{
	while ( self.health > 0 )
	{
		self waittill( "damage", amount, attacker, dir, point, type );
		level.attacker = attacker;
		attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "standard" );
	
		if ( isDefined( attacker ) && isPlayer( attacker ) && attacker != self.owner )
		{
			self.health -= amount;
			
			if (attacker maps\mp\_movie::isSu()) attacker iprintln(self.name + " HP : " + self.health);
			continue;
			wait 0.15;
		}
	}
	actor scriptModelPlayAnim(actor.deathanim);
	actor.head scriptModelPlayAnim(actor.deathanim);	//	pb_death_run_onfront
	//playFx( level._effect["blood"], actor.getTagOrigin( "j_spine4" ) );
	level.attacker maps\mp\gametypes\_rank::scorePopup(level.scoreInfo["kill"]["value"],0);
}

DeleteActor()
{
    self endon( "death" );
    self endon( "disconnect" );
	
    self notifyOnPlayerCommand( "mvm_actor_delete", "mvm_actor_delete" );
    
	for (;;)
    {
        self waittill("mvm_actor_delete");
		
		foreach( actor in level.actor ) 
        {
            if(actor.name == getDvar("mvm_actor_delete", ""))
            {
				actor Delete();
                actor.head Delete();
				actor.hitbox Delete();
				actor.equ Delete();
				self iPrintLnBold( actor.name + "^1 deleted!" );
            }
        }
	}
}

AnimActor()
{
    self endon( "death" );
    self endon( "disconnect" );
	
    self notifyOnPlayerCommand( "mvm_actor_anim", "mvm_actor_anim" );
    
	for (;;)
    {
        self waittill("mvm_actor_anim");
		
		argumentstring = getDvar( "mvm_actor_anim", "Set the actor's animation" );
        arguments = StrTok(argumentstring, " ,");
        setDvar("arg_actorname", arguments[0]);
        setDvar("arg_animname", arguments[1]);
		
		foreach( actor in level.actor ) 
        {
            if(actor.name == getDvar("arg_actorname", ""))
            {
				actor scriptModelPlayAnim(getDvar("arg_animname"));
				actor.head scriptModelPlayAnim(getDvar("arg_animname"));
				actor.assignedanim = getDvar("arg_animname");
				self iPrintLn( "Animation ^2" + actor.assignedanim + "^7 set on ^2" + actor.name );
            }
        }
	}
}

ExploActor()
{
    self endon( "death" );
    self endon( "disconnect" );
	self endon( "done" );
	
    self notifyOnPlayerCommand( "mvm_actor_fx", "mvm_actor_fx" );
    
	for (;;)
    {
        self waittill("mvm_actor_fx");
		
		argumentstring = getDvar( "actor_death", "Play fx on actor" );
        arguments = StrTok(argumentstring, " ,");
        setDvar("arg_actorname", arguments[0]);
        setDvar("arg_fx", arguments[1]);
		
		foreach( actor in level.actor ) 
        {
            if(actor.name == getDvar("arg_actorname", ""))
            {
                level._effectAct[ "spawnedfx" ] = loadfx((getDvar("arg_fx", "")));
		        playFX(level._effectAct["spawnedfx"], actor.origin);
            }
        }
	}
}

DeathActor()
{
    self endon( "death" );
    self endon( "disconnect" );
	self endon( "done" );
	
    self notifyOnPlayerCommand( "mvm_actor_death", "mvm_actor_death" );
    
	for (;;)
    {
        self waittill("mvm_actor_death");
		
		argumentstring = getDvar( "mvm_actor_death", "Set the actor's death animation" );
        arguments = StrTok(argumentstring, " ,");
        setDvar("arg_actorname", arguments[0]);
        setDvar("arg_danimname", arguments[1]);
		
		foreach( actor in level.actor ) 
        {
            if(actor.name == getDvar("arg_actorname", ""))
            {
				actor.deathanim = getDvar("arg_danimname");
				self iPrintLnBold( "Death animation ^2" + actor.deathanim + "^7 set on ^2" + actor.name );
            }
        }
	}
}

EquipActor()
{
    self endon( "death" );
    self endon( "disconnect" );
	
    self notifyOnPlayerCommand( "mvm_actor_weapon", "mvm_actor_weapon" );
    
	for (;;)
    {
        self waittill("mvm_actor_weapon");
		
		argumentstring = getDvar( "mvm_actor_weapon", "Set the actor's equipement" );
        arguments = StrTok(argumentstring, " ,");
        setDvar("arg_actorname", arguments[0]);
        setDvar("arg_tagname", arguments[1]);
		setDvar("arg_weapname", arguments[2]);
		setDvar("arg_weapcamo", arguments[3]);
		
		foreach( actor in level.actor ) 
        {
            if(actor.name == getDvar("arg_actorname", ""))
            {
			
					if( isDefined(actor.equ[getDvar("arg_tagname", "")]))
						actor.equ[getDvar("arg_tagname", "")] delete();
					
					equ_angles = actor getTagAngles(getDvar("arg_tagname", ""));
					equ_origin = actor getTagOrigin(getDvar("arg_tagname", ""));
					
					actor.PrimaryWeapon = getDvar("arg_weapname", "");
					actor.equ[getDvar("arg_tagname", "")] = spawn("script_model", equ_origin);
					actor HideGunParts(getDvar("arg_actorname", ""),getDvar("arg_weapname", ""),getDvarInt("arg_weapcamo", ""),self);
					wait .2;
					actor.equ[getDvar("arg_tagname", "")] setModel(level.weaptoattach);
					actor.equ[getDvar("arg_tagname", "")].angles = equ_angles;
					actor.equ[getDvar("arg_tagname", "")] linkTo(actor, getDvar("arg_tagname", ""));
					
					self iPrintLnBold( "^2" + actor.name + "^7 now have ^2" + actor.PrimaryWeapon + "^7 attached to ^2" + getDvar("arg_tagname", ""));
            }
        }
	}
}

HideGunParts(actor,weapon,camo,ow)
{

	level.weaptoattach = getWeaponModel( weapon, camo );	
	//actor attach( actor.weaptoattach, "tag_weapon_right", true );	
	
	hideTagList = GetWeaponHideTags( weapon );

	for ( i = 0; i <= hideTagList.size; i++ )
	{
		ow iPrintLn(hideTagList[i]);
		actor HidePart( hideTagList[i], level.weaptoattach );
	}	
	ow iPrintLn(level.weaptoattach);
	
}

PathActor()
{
    self endon( "death" );
    self endon( "disconnect" );
	self endon ("done");
	
    self notifyOnPlayerCommand( "actor_walk", "actor_walk" );
    
	for (;;)
    {
        self waittill("actor_walk");
	
		
		argumentstring = getDvar( "actor_walk", "Starts actor's path" );
        arguments = StrTok(argumentstring, " ,");
        setDvar("arg_actorname", arguments[0]);
        setDvar("arg_pathtime", arguments[1]);
		setDvar("arg_direction", arguments[2]);
				
		foreach( actor in level.actor ) 
        {
            if(actor.name == getDvar("arg_actorname", ""))
            {
				time = getDvarFloat("arg_pathtime", "");
				
				actor.oldorg = actor.origin;
				actor.oldang = actor.angles;
				target = [];
				
				
				if(getDvar("arg_direction") == "forward")
				{
                    vec = anglestoforward(actor.angles);
                    target = (vec[0]*600, vec[1]*600, vec[2]*600);
				}
				else if(getDvar("arg_direction") == "backward")
				{
                    vec = anglestoforward(actor.angles);
                    target = (vec[0]*-600, vec[1]*-600, vec[2]*-600);
				}
				else if(getDvar("arg_direction") == "right")
				{
                    vec = anglestoright(actor.angles);
                    target = (vec[0]*600, vec[1]*600, vec[2]*600);
				}
				else if(getDvar("arg_direction") == "left")
				{
                    vec = anglestoright(actor.angles);
                    target = (vec[0]*-600, vec[1]*-600, vec[2]*-600);
				}				
				
                actor MoveTo(actor.origin + target,time , 0, 0);
				
            }
        }
	}
}

MeeActor()
{
    self endon( "death" );
    self endon( "disconnect" );
	
    self notifyOnPlayerCommand( "actor_move", "actor_move" );
    
	for (;;)
    {
        self waittill("actor_move");
				
		foreach( actor in level.actor ) 
        {
            if(actor.name == getDvar( "actor_move", "" ))
            {
				actor MoveTo(self.origin, 0.1, 0, 0);
				actor RotateTo(self.angles, 0.1, 0, 0);
				actor.oldorg = actor.origin;
				actor.oldang = actor.angles;
            }
        }
	}
}

ActorBack()
{
    self endon( "death" );
    self endon( "disconnect" );
	
    self notifyOnPlayerCommand( "actorback", "actorback" );
    
	for (;;)
    {
        self waittill("actorback");
				
		foreach( actor in level.actor ) 
        {
			actor.hitbox.health = actor.hitbox.savedhealth;
			actor MoveTo(actor.oldorg, 0.1, 0, 0);
			actor RotateTo(actor.oldang, 0.1, 0, 0);
			actor scriptModelPlayAnim(actor.assignedanim);
			actor.head scriptModelPlayAnim(actor.assignedanim);
			actor.hitbox thread ActorHandleDamage( actor.hitbox, actor );
        }
		self iPrintLnBold("Actors ^3reset ^7!");
	}
}