/**
 *	SASS' CINEMATIC MOD --- "Camera" file
 *	Version : #283
 *	
 *	GitHub  : https://github.com/sasseries/iw4-cine-mod
 *	Discord : sass#1997
 */

#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#using_animtree( "destructibles" );

cam()
{
	level thread CamConnect();
}

CamConnect()
{
    for(;;)
    {
		level waittill( "connected", player );
		level.cam["poscount"] = 0;
		level.cam["type"] = "bezier";
        player thread CSpawn();
    }
}

CSpawn()
{
    self endon( "disconnect" );
    for(;;)
    {
		self waittill("spawned_player");

		setDvar("camera_thirdperson", "0");
		self show();

		setDvarIfUninitialized( "sv_fps", "20" );

		//----------------------------------
		// CAM NODES MANAGING
		thread SaveCamPos();
		thread SaveAngles();
		thread ResetCamPos();
		thread SetCamMode();
		thread CameraStart();
		//----------------------------------
		// DEBUG
		thread InitGrenadeCam();
		thread CamDebug();	

		
    }
}


UpdatePath() 
{
	
	level.cam["path"] = [];
	level.cam["node"] = [];
	level.campathtotal = 0;
	
	if(level.cam["type"] == "bezier")
	{
		level.pathsteps = (2000 * level.cam["poscount"]/400);
		for(j = 0; j < (level.pathsteps) ; j++)
		{
			t = j/(level.pathsteps - 1);
			vect[0]  = 0; vect[1]  = 0; vect[2]  = 0;
			angle[0] = 0; angle[1] = 0; angle[2] = 0;

			for(i=1 ; i<=level.cam["poscount"] ; i++)
			{
				for(z = 0; z < 3; z++)
				{
					vect[z]  +=float(koeff(i-1,level.cam["poscount"]-1)*pow((1-t),level.cam["poscount"]-i)*pow(t,i-1)*level.cam["orgpath"][i][z]);
					angle[z] +=float(koeff(i-1,level.cam["poscount"]-1)*pow((1-t),level.cam["poscount"]-i)*pow(t,i-1)*level.cam["angles"][i][z]);
				}
			}
		level.cam[level.campathtotal]["path"] = spawn( "script_model", (vect[0],vect[1],vect[2]) );
		level.cam[level.campathtotal]["path"] setModel( "projectile_semtex_grenade_bombsquad" );
		level.cam[level.campathtotal]["path"].angles = (angle[0],angle[1],angle[2]);
		level.campathtotal++;
		}
	}
	else if(level.cam["type"] == "linear")
	{	
		for (i=1 ; i < level.cam["poscount"] ; i++)
		{
			wait .05;
			level.cam[i]["node"] = spawn( "script_model", level.cam["orgpath"][i] );
			level.cam[i]["node"].angles = VectorToAngles(level.cam["orgpath"][i+1] - level.cam["orgpath"][i]);
			level.cam[i]["node"] setModel( "tag_origin" );
		
			
			if( (distance(level.cam["orgpath"][i],level.cam["orgpath"][i+1])) > 500 )
				level.pathsteps = 18; 
			else level.pathsteps = 8; // Good enough for most of distances
			
			for (j=0 ; j < level.pathsteps ; j++)
			{
				vec = anglestoforward(level.cam[i]["node"].angles);
				
				total = (distance(level.cam["orgpath"][i],level.cam["orgpath"][i+1]))/level.pathsteps;
				
				
				target = ( vec[0]*(total*j), vec[1]*(total*j), vec[2]*(total*j) );
			
				level.cam[level.campathtotal]["path"] = spawn( "script_model", level.cam[i]["node"].origin + target );
				level.cam[level.campathtotal]["path"] setModel( "projectile_semtex_grenade_bombsquad" );
				level.campathtotal++;
			}
		}

	}

	else self IPrintLn("^1ERROR ^7: Couldn't draw ^1" + level.cam["type"] + " ^7type path !!");
}



DeletePath()
{
	foreach( cam in level.cam )
	{
		cam["path"] delete();
		cam["node"] delete();
	}
}

fix360Angles()
{
	for (j=0; j < level.cam["poscount"]; j++)
	{
		for(i = 0; i < level.cam["poscount"] - 1; i++)
		{
			x = level.cam["angles"][i][1];
			y = level.cam["angles"][i+1][1];

			if(y - x >=180)
				level.cam["angles"][i] += (0,360,0);
			else if(y - x <= -180)
				level.cam["angles"][i+1]+=(0,360,0);
		}
	}
}

SetCamMode()
{
	self endon("disconnect");
	self endon("death");

	setDvarIfUninitialized( "mvm_cam_mode", "mode - ^3Set the camera mode" );
	self notifyOnPlayerCommand("mvm_cam_mode", "mvm_cam_mode");
	for ( ;; )
	{

		self waittill("mvm_cam_mode");
        
		level.cam["type"] = getDvar("mvm_cam_mode", "");
        self DeletePath();
		
		if((level.cam["type"] == "bezier" && level.cam["poscount"] <= 13) || level.cam["type"] == "linear" /*|| level.cam["type"] == "cubic"*/)
		{
			self IPrintLn("^3Camera mode ^7has been set to ^3" + level.cam["type"]);
			self SetClientDvar("movie_curvetype", level.cam["type"]);
			self UpdatePath(level.cam["type"]);
			
		}
		else if( (level.cam["type"] == "bezier" && level.cam["poscount"] > 13) )
			self IPrintLn("^1ERROR ^7: Can't calculate ^3bezier ^7path with ^3" + level.cam["poscount"] + " ^7nodes (13 max)");
		
		else self IPrintLn("^1ERROR ^7: Camera mode ^1" + level.cam["type"] + " ^7doesn't exist !!");
	
   	
   	}
}


SaveCamPos()
{
	self endon("disconnect");
	self endon("death");

	setDvarIfUninitialized( "mvm_cam_save", "number - ^3Save camera point" );
	self notifyOnPlayerCommand("mvm_cam_save", "mvm_cam_save");
	for ( ;; )
	{

		self waittill("mvm_cam_save");
		
		if( self.sessionstate == "playing")
		{
			self IPrintLn("Enter in ^3noclip ^7mode to ^3save ^7!");
			self suicide();
		}
		

		f = getDvarInt("mvm_cam_save", "");
		
		if(level.cam["type"] == "bezier" && f > 13)
		{
			self IPrintLn("^1ERROR ^7: Can't save ^1more than 13 points ^7in ^1bezier ^7mode !!");
			self.sessionstate = "playing";
			wait .1;
			self suicide();
		}
		
		self DeletePath();

	
		level.cam["origin"][f] = self GetOrigin() + (0,0,-58);
		level.cam["orgpath"][f] = self GetOrigin();
		level.cam["angles"][f] = self GetPlayerAngles();
		level.cam["ups"][f] = AnglesToUp( self GetPlayerAngles() );
		
		if(isDefined(level.cam[f]["obj"])) level.cam[f]["obj"] delete();
		level.cam[f]["obj"] = spawn("script_model", self.origin);
		level.cam[f]["obj"] setModel("projectile_rpg7");
		level.cam[f]["obj"].angles = self GetPlayerAngles();
		
		if(level.cam["poscount"] <= f) level.cam["poscount"] = f;
		
		self IPrintLn("Position^3 " + f + " ^7saved : " + self.origin );
		self UpdatePath();
		
   	}
}


ResetCamPos()
{
    self endon( "death" );
    self endon( "disconnect" );
	
	setDvarIfUninitialized( "mvm_cam_delete", "number - ^3Delete defined camera node and above" );
    self notifyOnPlayerCommand( "mvm_cam_delete", "mvm_cam_delete" );
    
	for (;;)
    {
        self waittill("mvm_cam_delete");
		
		d = getDvar("mvm_cam_delete", "");
		f = getDvarInt("mvm_cam_delete", "");

		self deletepath();
		
		if( level.cam["poscount"] == 0 ) 
			self IPrintLn("There's nothing to delete");
		else if( d == "all" || f == 1)
		{		
			for (i=0 ; i<=level.cam["poscount"] ; i++)
			{
				level.cam["origin"][i] = undefined;
				level.cam["angles"][i] = undefined;
				level.cam[i]["obj"] Delete();
			}
			self iPrintLn( "^3All ^7positions ^3deleted^7!" );
			level.cam["poscount"] = 0;
		}
		else if( f > 0 )
		{		
			for (i=f ; i<=level.cam["poscount"] ; i++)
			{
				level.cam["origin"][i] = undefined;
				level.cam["angles"][i] = undefined;
				level.cam[i]["obj"] Delete();
			}
			level.cam["poscount"] = f-1;
			self UpdatePath();
			
			self iPrintLn( "Position number ^3" + f + " ^7and above ^3deleted^7!" );
		}

		else self IPrintLn("^1Looks like you typed something wrong");
		
		wait .1;
	}
}


SaveAngles()
{
    self endon( "death" ); 
    self endon( "disconnect" );
	
	setDvarIfUninitialized( "mvm_cam_rot", "angle - ^3Add angle rotation (in degrees)" );
    self notifyOnPlayerCommand( "mvm_cam_rot", "mvm_cam_rot" );
    for(;;)
    {
		self waittill( "mvm_cam_rot" );
        
		level.player SetPlayerAngles(self GetPlayerAngles() + (0, 0, getDvarFloat("mvm_cam_rot", "")));
		self IPrintLn("^3Angle ^7changed to : " + getDvarFloat("mvm_cam_rot", "") + " ");
		wait(0.2);
    }
}


CameraStart()
{
	self endon("disconnect");
	self endon("death");
	setDvarIfUninitialized( "mvm_cam_start", "time/speed - ^3Starts flight (Bezier = Speed / Linear = Time)" );
	self notifyOnplayerCommand( "mvm_cam_start", "mvm_cam_start" );

	for(;;)
    {
		self waittill("mvm_cam_start");
		
		level.cam["speed"] = getDvarFloat("mvm_cam_start");
		
		self.sessionstate = "playing";
		self.orgBackup = self GetOrigin();
		self.angBackup = self GetPlayerAngles();
		self VerifyPath();
		self setClientDvar("cg_drawgun", 0);
		
		// Creating camera object + debug
		self SetOrigin(self.saved_originstart);
		self SetPlayerAngles(self.saved_anglesstart);
		camera = spawn( "script_model", self.origin );
		camera setModel( "tag_origin" );
		camera EnableLinkTo();
		camera RotateTo( self.angles );
		wait 0.01;
		
		// Linking player to camera object
		self PlayerLinkTo( camera, "tag_origin", 1, 360, 360, 360, 360, false );
		camera RotateTo( level.cam["angles"][1], 0.2, 0, 0 );
		camera MoveTo( level.cam["origin"][1], 0.2, 0, 0 );
		
		// Message + Countdown
		if(level.cam["type"] == "linear" ) level.cam["unit"] = "seconds";
		else level.cam["unit"] = "speed";
		self IPrintLn("Starting ^3" + level.cam["type"] + " ^7cam : ^3" + getDvarFloat("mvm_cam_start") + " ^7" + level.cam["unit"]);
		self thread HideCamNode();
		self thread Countdown();
		wait 2;
		
		// Fly
		self thread Prepare();	
		self setClientDvar("cg_draw2d", 0);		
		self CameraFly(camera, level.cam["type"],level.cam["speed"]);
	
		// When fly is done
		self Unlink();
		wait 0.05;
		setDvar("cg_draw2D", "1");
		setDvar("cg_drawGun", "1");
		self thread ShowCamNode();
		self SetOrigin(self.orgBackup);
		self SetPlayerAngles(self.angBackup);
		
		//Noclip thread needs to be restarted. Odd
		self notify("killnoclip");
		thread maps\mp\_misc::noclip();
	}
}

CameraFly(camera, type, speed)
{
	if(type == "linear")
	{
		for (i=2 ; i < level.cam["poscount"] + 1 ; i++)
		{
			camera RotateTo( level.cam["angles"][i], level.cam["speed"] / level.cam["poscount"], 0, 0 );
			camera MoveTo( level.cam["origin"][i], level.cam["speed"] / level.cam["poscount"], 0, 0 );
			wait ( level.cam["speed"] / level.cam["poscount"] );
		}
	}
	else if(type == "bezier")
	{
		dist = level.alldist;
		level.multiplier = getDvarint("sv_fps") / 100 ;
        
        
        for(j = 0; j <= dist*10*level.multiplier/speed ; j++)
		{
			t = (j*speed/(dist * 10 * level.multiplier));
			vect[0]  = 0; vect[1]  = 0; vect[2]  = 0;
			angle[0] = 0; angle[1] = 0; angle[2] = 0;

			for(i=1 ; i<=level.cam["poscount"] ; i++)
			{
				for(z = 0; z < 3; z++)
				{
					vect[z]  +=float(koeff(i-1,level.cam["poscount"]-1)*pow((1-t),level.cam["poscount"]-i)*pow(t,i-1)*level.cam["origin"][i][z]);
					angle[z] +=float(koeff(i-1,level.cam["poscount"]-1)*pow((1-t),level.cam["poscount"]-i)*pow(t,i-1)*level.cam["angles"][i][z]);
				}
			}
            camera MoveTo((vect[0],vect[1],vect[2]), .1, 0, 0);
            camera RotateTo((angle[0],angle[1],angle[2]), .1, 0, 0);
            wait .01;
		}
		wait 0.1;
	}
}

VerifyPath()
{
	if(level.cam["type"] != "bezier" && level.cam["type"] != "linear" && level.cam["type"] != "cubic")
	{
		self IPrintLn("^1ERROR ^7: ^3" + level.cam["type"] + " ^7camera type doesn't exist !!");
		self.sessionstate = "playing";		
		wait .1;
		self suicide();
	}
	if(level.cam["poscount"] <= 1)
	{
		self IPrintLn("^1ERROR ^7: Camera path needs atleast^3 2 ^7points to ^3start ^7!!");
		self.sessionstate = "playing";		
		wait .1;
		self suicide();
	}
	if(level.cam["type"] == "bezier" && level.cam["poscount"] > 13)
	{
		self IPrintLn("^1ERROR ^7: Couldn't calculate ^3bezier ^7path with ^3" + level.cam["poscount"] + " ^7nodes !!");
		self.sessionstate = "playing";		
		wait .1;
		self suicide();
	}
	if(level.cam["speed"] <= 0)
	{
		self IPrintLn("^1ERROR ^7: Couldn't ^3draw a path ^7with a ^3" + level.cam["speed"] + " ^7speed !!");
		self.sessionstate = "playing";		
		wait .1;
		self suicide();
	}
}

Prepare() 
{
	level.alldist = 0;
	for(k=1; k<level.cam["poscount"]; k++)
	{
		x=level.cam["angles"][k][1];
		y=level.cam["angles"][k+1][1];
		
		if(y - x >= 180)
		{
		 level.cam["angles"][k]+=(0,360,0);
		}

		else if(y - x <= -180)
		{
		 level.cam["angles"][k+1]+=(0,360,0);
		}

		level.partdist[k] = distance(level.cam["origin"][k], level.cam["origin"][k+1] );
		level.angledist[k] = distance(level.cam["angles"][k], level.cam["angles"][k+1]);
		level.alldist+=level.partdist[k];
		level.alldist+=level.angledist[k];
	}
}

InitGrenadeCam()
{
    self endon("death");
    self endon("disconnect");
	
	setDvarIfUninitialized( "mvm_cam_nade", "*toggle* - ^3Toggle grenade camera" );
    self notifyOnPlayerCommand( "mvm_cam_nade", "mvm_cam_nade" );
    for(;;)
    {
        self waittill("mvm_cam_nade");

        if( !isDefined(self.nademode))
        {
        self thread GrenadeCam();
        self iPrintLn( "^3Grenade Cam - ^2ON" );
        self.nademode = 1;
        }
        else if(self.nademode == 1)
        {
        self notify("endnade");
        self iPrintLn( "^3Grenade Cam - ^1OFF" );
        self.nademode = undefined;
        }
    }
}

GrenadeCam()
{
	self endon("endnade");
	self endon("disconnect");
	
	for(;;)
            {
           	self waittill ( "grenade_fire", grenade, weaponName );
                self playerlinktoDelta( grenade, undefined, 50);
				setDvar("camera_thirdperson", "1");
				setDvar("camera_thirdpersonoffset", "0 0 45");
                self setorigin(grenade.origin + ( 0, 0, 180 )  );
				while(isdefined(grenade))
                wait 0.05;
            }
     
}

CamDebug()
{
	if( !isDefined(self.saved_originstart) )
	{
        self.saved_originstart = self GetOrigin();
        self.saved_anglesstart = (0,360,0);
        level.cam["poscount"] = 0;
	}
}

Countdown()
{
	dur = 2;
	bar = createPrimaryProgressBar( -20 );
	txt = createPrimaryProgressBarText( -20 );
	txt setText( level.cam["type"] + " cam : " + level.cam["speed"] + " " + level.cam["unit"]);
	bar updateBar( 0, 1 / dur );
	bar.color = (0.2, 0.2, 0.2);
	bar.bar.color = (0.9, 0.9, 0.9);
	for ( waitedTime = 0 ; waitedTime < dur ; waitedTime += 0.05 ) wait ( 0.05 );
	bar destroyElem();
	txt destroyElem();
}


HideCamNode()
{
    self endon( "disconnect" );
	self endon( "fin" );
	foreach( cam in level.cam ) 
    {
			cam["obj"] hide();
			cam["path"] hide();
	}
	wait .1;
}

ShowCamNode()
{
    self endon( "disconnect" );
	foreach( cam in level.cam ) 
    {
			cam["obj"] show();
			cam["path"] show();
	}
	wait .1;
}

float(var) 
{
  	setDvar("temp",var);
  	return getDvarfloat("temp");
}

koeff(x,y)
{
	return (fact(y)/(fact(x)*fact(y-x)));
}

fact(x)
{
	c=1;
	if(x==0) return 1;
	for(i=1;i<=x;i++)
		c=c*i;
	return c;
}

pow(a,b)
{
  	x=1;
  	if(b!=0){
  		for(i=1;i<=b;i++)
  			x=x*a;
  	}
  	return x;
}

mod(a) 
{
  	 if (a >= 0) return a;
  	 else return a * (-1);
}

crossProduct(vecA, vecB)
{
  a = (vecA[1] * vecB[2]) - (vecA[2] * vecB[1]);
  b = (vecA[2] * vecB[0]) - (vecA[0] * vecB[2]);
  c = (vecA[0] * vecB[1]) - (vecA[1] * vecB[0]);
  return (a,b,c);
}

getPointOnSpline(cubic, s)
{
  return (((cubic.d * s) + cubic.c) * s + cubic.b) *s +cubic.a;
}

calcCubicSpline(n, v)
{
  gamma = []; 
  delta = []; 
  D = []; 

  gamma[0] = (0.5,0.5,0.5);

  for(i = 1; i < n; i++){
    gamma[i] = (1,1,1) / ((4*(1,1,1)) - gamma[i - 1]);
  }
  gamma[n] = (1,1,1) / ((2 * (1,1,1)) - gamma[n - 1]);

  delta[0] = 3 * ((v[1] - v[0])) * gamma[0];
  for( i = 1; i < n ; i++){
    delta[i] = (3 * ((v[i + 1] - v[i-1])) - delta[i-1]) * gamma[i];
  }
  delta[n] = (3 * ((v[n] - v[n-1])) - delta[n - 1]) * gamma[n];

  D[n] = delta[n];
  for(i = n - 1; i >= 0; i--){
    D[i] = delta[i] - gamma[i] * D[i + 1];
  }

  C = [];
  for( i = 0; i < n; i++){
    C[i] = createCubic(v[i], D[i], 3 * ((v[i + 1] - v[i])) - 2 * D[i] - D[i + 1], 2 * ((v[i] - v[i + 1])) + D[i] + D[i + 1]);
  }
  return C;
}


createCubic(a,b,c,d)
{
  cubic = SpawnStruct();
  cubic.a = a;
  cubic.b = b;
  cubic.c = c;
  cubic.d = d;
  return cubic;
}
