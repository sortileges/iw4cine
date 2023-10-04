/*
 *      IW4 Cine
 *      Precache
 *      
 *      >>>  IMPORTANT :
 *      - EVERY animation needs to be precached
 *      - Multiplayer playermodels don't need to be precached, but Singleplayer ones do
 *
 *      >>>  WHERE TO FIND :
 *      List of MP models : https://pastebin.com/raw/0a53Npp8
 *      List of MP anims : https://pastebin.com/raw/KGbrSCdx
 *
 *      >>>  HOW TO USE :
 *      Put your precache between the "{ }" brackets below custom_precache()
 *      precacheModel( "name_of_model" );
 *      precacheMPAnim( "name_of_anim" );
 */

custom_precache()
{

}









// Anything below this point is a no-touch zone, unless you know what you're removing
common_precache()
{
    precacheModel( "defaultactor" );
    precacheModel( "projectile_rpg7" );
    precacheModel( "projectile_semtex_grenade_bombsquad" );
    precacheModel( "tag_origin" );
    precacheModel( "com_plasticcase_enemy" );
    precacheMPAnim( "pb_stand_remotecontroller" );
    precacheMPAnim( "pb_stand_death_chest_blowback" );
}

fx_precache()
{
    // later
}