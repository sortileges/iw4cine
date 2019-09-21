#include maps\mp\_utility;
#include common_scripts\utility;

precache()
{
	PrecacheMPAnim("pb_sprint");
	PrecacheMPAnim("pb_stand_alert");
	PrecacheMPAnim("pb_stand_death_chest_blowback");
	PrecacheModel("defaultactor");
	PrecacheModel("projectile_rpg7");
	PrecacheModel("projectile_semtex_grenade_bombsquad");
	
	// ^^^^^^^^^^^ DO NOT REMOVE ANY OF THESE !!!!!!!

    // You need to put your own precache in here from the link below. 
	// https://pastebin.com/raw/KGbrSCdx
    // Pick 20-30 anims maximum to avoid overflow



}