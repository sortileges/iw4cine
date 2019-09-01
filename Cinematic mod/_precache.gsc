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
    // You need to put your own precache in here from the list below. 
    // YOU CANT JUST PUT EVERYTHING!! Pick 20-30 anims maximum
    // Just copy/paste what you need between this line and the "}" below



}


/*
    # LIST OF ALL MULTIPLAYER ANIMS YOU NEED
	# THESE ARE NOT PRECACHED, YOU'LL HAVE TO DO IT YOURSELF 
	# PLEASE FOLLOW THE INSTRUCTIONS ABOVE

    #-------------------------
	# SPRINT ANIMS
   	PrecacheMPAnim("pb_pistol_run_fast");
	PrecacheMPAnim("pb_run_fast");
	PrecacheMPAnim("pb_sprint");
	PrecacheMPAnim("pb_sprint_gundown");
	PrecacheMPAnim("pb_sprint_RPG");
	PrecacheMPAnim("pb_sprint_pistol");
	PrecacheMPAnim("pb_sprint_hold");
	PrecacheMPAnim("pb_sprint_akimbo");
	PrecacheMpAnim("pb_sprint_shield");

	#-------------------------
	# MISC ANIMS
	PrecacheMPAnim("pb_walk_forward_shield");
	PrecacheMPAnim("pb_walk_forward_akimbo");
	PrecacheMPAnim("pb_climbup");
	PrecacheMPAnim("pb_climbdown");
	PrecacheMPAnim("pb_prone2crouch");
	PrecacheMPAnim("pb_runjump_land");
	PrecacheMPAnim("pb_runjump_takeoff");

	#-------------------------
	# DEATH ANIMS
	precacheMPAnim("pb_explosive_round_death_leg");
	precacheMPAnim("pb_explosive_round_death_jaw");
	precacheMPAnim("pb_explosive_round_death_chestB");
	precacheMPAnim("pb_explosive_round_death_chestA");
	precacheMPAnim("pb_prone_death_quickdeath");
	precacheMPAnim("pb_crouch_death_headshot_front");
	precacheMPAnim("pb_crouch_death_clutchchest");
	precacheMPAnim("pb_crouch_death_flip");
	precacheMPAnim("pb_crouch_death_fetal");
	precacheMPAnim("pb_crouch_death_falltohands");
	precacheMPAnim("pb_crouchrun_death_drop");
	precacheMPAnim("pb_crouchrun_death_crumple");
	precacheMPAnim("pb_stand_death_legs");
	precacheMPAnim("pb_stand_death_lowerback");
	precacheMPAnim("pb_stand_death_head_collapse");
	precacheMPAnim("pb_stand_death_neckdeath_thrash");
	precacheMPAnim("pb_stand_death_neckdeath");
	precacheMPAnim("pb_stand_death_nervedeath");
	precacheMPAnim("pb_stand_death_frontspin");
	precacheMPAnim("pb_stand_death_headchest_topple");
	precacheMPAnim("pb_stand_death_chest_blowback");
	precacheMPAnim("pb_stand_death_chest_spin");
	precacheMPAnim("pb_stand_death_shoulder_stumble");
	precacheMPAnim("pb_stand_death_head_straight_back");
	precacheMPAnim("pb_stand_death_tumbleback");
	precacheMPAnim("pb_stand_death_kickup");
	precacheMPAnim("pb_stand_death_stumbleforward");
	precacheMPAnim("pb_stand_death_leg");
	precacheMPAnim("pb_stand_death_leg_kickup");
	precacheMPAnim("pb_stand_death_headshot_slowfall");
	precacheMPAnim("pb_stand_death_shoulderback");
	precacheMPAnim("pb_death_run_forward_crumple");
	precacheMPAnim("pb_death_run_onfront");
	precacheMPAnim("pb_death_run_stumble");
	precacheMPAnim("pb_death_run_back");
	precacheMPAnim("pb_death_run_left");
	precacheMPAnim("pb_death_run_right");
	precacheMPAnim("MP_shotgun_death_back");
	precacheMPAnim("MP_shotgun_death_front");
	precacheMPAnim("MP_shotgun_death_left");
	precacheMPAnim("MP_shotgun_death_right");

	#-------------------------
	# DOLFIN DIVE ANIMS
	precacheMPAnim("pb_dive_right");
	precacheMPAnim("pb_dive_right_impact");
	precacheMPAnim("pb_dive_left");
	precacheMPAnim("pb_dive_left_impact");
	precacheMPAnim("pb_dive_back");
	precacheMPAnim("pb_dive_back_impact");
	precacheMPAnim("pb_dive_front");
	precacheMPAnim("pb_dive_front_impact"); 

*/