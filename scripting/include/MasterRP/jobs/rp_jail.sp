//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_jail_included_
  #endinput
#endif
#define _rp_jail_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = €

//Defines:
#define MAXJAILS		7
#define EXITID			10
#define VIPID			15
#define EXECUTEID		20
#define FIREPITID		25
#define JAIL			30

//Origins
float JailSellOrigin[MAXJAILS + 1][3];
float ExitOrigin[3] = { 0.0, 0.0, 0.0};
float VIPOrigin[3] = { 0.0, 0.0, 0.0};
float ExecuteOrigin[3] = { 0.0, 0.0, 0.0};
float FirePitOrigin[3] = { 0.0, 0.0, 0.0};
float JailOrigin[3] = { 0.0, 0.0, 0.0};

//Law:
int WhoCuffed[MAXPLAYERS + 1] = {-1,...};
int JailTime[MAXPLAYERS + 1] = {0,...};
int MaxJailTime[MAXPLAYERS + 1] = {0,...};
int Grabbing[MAXPLAYERS + 1] = {0,...};
int CuffColor[4] = {50, 50, 250, 200};
bool TimerExec[MAXPLAYERS + 1] = {false,...};

public void initJail()
{

	//Commands:
	RegAdminCmd("sm_cuff", Command_Cuff, ADMFLAG_SLAY, "<Name> - Cuffs player");

	RegAdminCmd("sm_uncuff", Command_UnCuff, ADMFLAG_SLAY, "<Name> - Uncuffs player");

	//Cop
	RegAdminCmd("sm_setexit", Command_SetExit, ADMFLAG_ROOT, "Set The position Of Jail Exit");

	RegAdminCmd("sm_setvipjail", Command_SetVipJail, ADMFLAG_ROOT, "Set The position Of Jail Exit");

	RegAdminCmd("sm_setjail", Command_AddJail, ADMFLAG_ROOT, "set the position of the jails");

	RegAdminCmd("sm_setsuicide", Command_SetSui, ADMFLAG_ROOT, "Set The position Of Suicide Chamber");

	RegAdminCmd("sm_setfirepit", Command_SetFirePit, ADMFLAG_ROOT, "Set The position Of Suicide Chamber");

	RegAdminCmd("sm_setjailorigin", Command_SetJailOrigin, ADMFLAG_ROOT, "Set The position Of instant teleport to jail");

	RegAdminCmd("sm_listjailspawns", Command_ViewJailSpawns, ADMFLAG_ROOT, "View ALl Spawns");

	RegConsoleCmd("sm_gotojail", Command_TeleportCopToJail);

	RegConsoleCmd("sm_bribe", Command_Bribe);

	//Timers:
	CreateTimer(0.2, CreateSQLdbJail);
}

public void IntJailTimer(int Client)
{

	//Is In Jail:
	if(JailTime[Client] != 0 && MaxJailTime[Client] != 0)
	{

		//Is Time Up:
		if((JailTime[Client] - 1 >= MaxJailTime[Client]))
		{

			//End Jail Timer:
			AutoFree(Client);
		}

		//Override:
		else
		{

			//Check:
			if(IsClientInJailSell(Client))
			{

				//Initialize:
				JailTime[Client] += 1;
			}
		}
	}
}

//Create Database:
public Action CreateSQLdbJail(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Jail`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `Id` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadJail(Handle Timer)
{

	//Loop:
	for(int Var = 1; Var <= MAXJAILS; Var++) 
	{

		//Loop:
		for(int X = 0; X <= 2; X++) 
		{

			//Initulize:
			JailSellOrigin[Var][X] = 69.0;
		}
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Jail WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadJail, query);
}

public void T_DBLoadJail(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadJail: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Jail Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0;
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, sizeof(Buffer));

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Is Jail:
			if(X <= MAXJAILS)
			{

				//Initulize:
				JailSellOrigin[X] = Position;
			}

			//Is Jail:
			if(X == EXITID)
			{

				//Initulize:
				ExitOrigin = Position;
			}

			//Is Jail:
			if(X == VIPID)
			{

				//Initulize:
				VIPOrigin = Position;
			}

			//Is Jail:
			if(X == EXECUTEID)
			{

				//Initulize:
				ExecuteOrigin = Position;
			}

			//Is Jail:
			if(X == FIREPITID)
			{

				//Initulize:
				FirePitOrigin = Position;
			}

			//Is Jail:
			if(X == JAIL)
			{

				//Initulize:
				JailOrigin = Position;
			}
		}

		//Print:
		PrintToServer("|RP| - Jail Found!");
	}
}

//Jail:
public void JailClient(int Client, int Cop)
{

	//Declare:
	int RandomInt = GetRandomInt(0, MAXJAILS);

	//Check:
	if(JailSellOrigin[RandomInt][0] != 69.0)
	{

		//Teleport:
		TeleportEntity(Client, JailSellOrigin[RandomInt], NULL_VECTOR, NULL_VECTOR);

		//Client Oposite: Player:
		if(Client != Cop)
		{

			//Print:
			if(Cop != Client) CPrintToChat(Cop, "\x07FF4040|RP|\x07FFFFFF - You send \x0732CD32%N\x07FFFFFF to jail", Client);

			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have been sent to jail by \x0732CD32%N", Cop);
		}
	}

	//Check:
	else if(!IsJailSetup())
	{

		//Print:
		if(Cop != Client) CPrintToChat(Cop, "\x07FF4040|RP|\x07FFFFFF - the jail origins havent been setup");

		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - the jail origins havent been setup");

		//Return:
		return;
	}

	//Override:
	else
	{

		//Restart Spawn:
		JailClient(Client, Cop);
	}

}

public void Execute(int Client, int Cop)
{

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have just Sent \x0732CD32%N\x07FFFFFF to the Execute Chamber!", Cop);

	CPrintToChat(Cop, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has just Sent you to the Excute Chamber!", Client);

	//Teleport:
	TeleportEntity(Client, ExecuteOrigin, NULL_VECTOR, NULL_VECTOR);
}

public void FirePit(int Client, int Cop)
{

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have just Sent \x0732CD32%N\x07FFFFFF to the Fire Pit!", Cop);

	CPrintToChat(Cop, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has just Sent you to the Fire Pit!", Client);

	//Teleport:
	TeleportEntity(Client, FirePitOrigin, NULL_VECTOR, NULL_VECTOR);
}

public void AutoFree(int Client)
{

	//Is Cuffed:
	if(TimerExec[Client] == true)
	{

		//Uncuff Client:
		UnCuff(Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are released from jail!");

		//Teleport:
		TeleportEntity(Client, ExitOrigin, NULL_VECTOR, NULL_VECTOR);
	}        
}

public void CalculateJail(int Client)
{

	//No Timer:
	if(MaxJailTime[Client] == 0)
	{

		//Declare:
		int Time = 0;

		//Has Enough Crime:
		if(GetCrime(Client) > 500)
		{

			//Has Enough Crime to Max Jail:
			if((GetCrime(Client) / 20) > 1200)
			{

				//Initialize:
            			Time = 1200;
			}

			//Override:
			else
			{

				//Initialize:
				Time = RoundToNearest(GetCrime(Client) / 20.0);
			}

		}

		if(Time < 180)
		{

			//Initulize:
			Time = 180;
		}

		//Save Jail Time:
		SetJailTime(Client, 1);

		SetMaxJailTime(Client, Time);

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "\x07FF4040|RP|\x07FFFFFF - You'll get free in \x0732CD32%i\x07FFFFFF minutes", RoundToNearest(Time/60.0));

		//Print:
		OverflowMessage(Client, query);
	}

	//Initialize:
	TimerExec[Client] = true;
}

//Cuff:
public void Cuff(int Client)
{

	//Set Speed:
	SetEntitySpeed(Client, 0.4);

	//Sent Ent Render:
	SetEntityRenderMode(Client, RENDER_GLOW);

	//Set Ent Color:
	SetEntityRenderColor(Client, CuffColor[0], CuffColor[1], CuffColor[2], CuffColor[3]);

	//Remove:
	//RemoveWeaponsInstant(Client);
	RemoveAllItems(Client, false);

	//Give Player Default Weapon:
	GiveClientWeapon(Client, GetDefaultWeapon(""));
#if defined HL2DM
	//Check:
	if(IsCustomGunsLoaded())
	{

		//Give Player Default Weapon:
		CG_ClearInventory(Client);
	}
#endif
	//Check:
	if(GetPostCrime(Client) != 0 && GetCrime(Client) > 0 && GetPostCrime(Client) != GetCrime(Client))
	{

		//Initulize:
		SetPostCrime(Client, GetCrime(Client));
	}
}

//UnCuff:
public void UnCuff(int Client)
{

	//Set Speed:
	SetEntitySpeed(Client, 1.0);

	//Sent Ent Render:
	SetEntityRenderMode(Client, RENDER_NORMAL);

	//Sent Ent Color:
	SetEntityRenderColor(Client, 255, 255, 255, 255);

	//Initialize:
	SetCrime(Client, 0);

	//Initulize:
	TimerExec[Client] = false;

	SetJailTime(Client, 0);

	SetMaxJailTime(Client, 0);

	SetPostCrime(Client, 0);

	WhoCuffed[Client] = -1;
#if defined HL2DM
	//Check:
	if(IsCustomGunsLoaded())
	{

		//Declare:
		//int ItemId = ConvertWeaponToItem("weapon_fists");
		int ItemId = 449;

		OnItemsWeaponUse(Client, ItemId, 1, false);
	}
#endif
}

//Is Player In Jail:
public bool IsClientInJailSell(int Client)
{

	//Declare:
	bool IsInJail = false;

	//Declare:
	float Origin[3];

	//Initulize:
	GetClientAbsOrigin(Client, Origin);

	//Loop:
	for(int X = 0; X <= MAXJAILS; X++)
	{

		//Declare:
		float Dist = GetVectorDistance(Origin, JailSellOrigin[X]);
	
		//Too Far Away:
		if(Dist <= 250)
		{

			//Initulize:
			IsInJail = true;

			//Break:
			break;
		}
	}

	//Declare:
	float Dist = GetVectorDistance(Origin, VIPOrigin);
	
	//Too Far Away:
	if(Dist <= 250)
	{

		//Initulize:
		IsInJail = true;
	}

	//Return:
	return view_as<bool>(IsInJail);
}

//Is Player In Jail:
public bool IsClientInJail(int Client)
{

	//Declare:
	bool IsInJail = false;

	//Declare:
	float Origin[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Data, "m_vecOrigin", Origin);

	//Declare:
	float Dist = GetVectorDistance(Origin, JailOrigin);
	
	//Too Far Away:
	if(Dist <= 750)
	{

		//Initulize:
		IsInJail = true;
	}

	//Return:
	return view_as<bool>(IsInJail);
}

//Is Player In Jail:
public bool IsJailSetup()
{

	//Declare:
	bool Result = false;

	//Loop:
	for(int X = 0; X <= MAXJAILS; X++)
	{

		//Check::
		if(JailSellOrigin[X][0] != 69.0)
		{

			//Initulize:
			Result = true;

			//Break:
			break;
		}
	}

	//Return:
	return view_as<bool>(Result);
}

public Action OnClientCuffCheck(int Client, int &Attacker, float &Damage)
{

	//Declare:
	char WeaponName[32];

	//Initulize;
	GetClientWeapon(Attacker, WeaponName, sizeof(WeaponName));

	//Is Stun Stick:
	if(StrEqual(WeaponName, GetArrestWeapon(), false))
	{

		//Is Cop:
		if((!IsCop(Client) && IsCop(Attacker)) || IsAdmin(Attacker))
		{

			//Declare:
			float ClientOrigin[3];
			float EntOrigin[3];

			//Initialize:
			GetClientAbsOrigin(Client, ClientOrigin);

			GetClientAbsOrigin(Attacker, EntOrigin);

			//Declare:
			float Dist = GetVectorDistance(ClientOrigin, EntOrigin);

			//In Distance:	
			if(Dist <= 150)
			{

				//Is Client Cuffed:
				if((IsCuffed(Client) && IsCopUnCuffDisabled() == 0 && IsCop(Attacker)) || (IsCuffed(Client) && IsAdmin(Attacker)))
				{

					//UnCuff Client:
					UnCuff(Client);

					//Print:
					CPrintToChat(Attacker, "\x07FF4040|RP|\x07FFFFFF - You uncuff \x0732CD32%N\x07FFFFFF!", Client);

					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You're uncuffed by \x0732CD32%N\x07FFFFFF.", Attacker);

					//Check:
					if(IsCuffDamageDisabled() == 1)
					{

						//Initialize:
						Damage = 0.0;
					}
				}

				//Is Not Cuffed + Has Crime:
				else if(GetCrime(Client) > 2500)
				{

					//Initulize:
					OnPlayerCuffGangCheck(Client, Attacker);

					//Declare:
					int HadBounty = GetBounty(Client);

					//Cuff Player:
					Cuff(Client);

					//Jail Time:
					CalculateJail(Client);

					//Initialize:
					SetCrime(Client, 0);

					SetBounty(Client, 0);

					WhoCuffed[Client] = Attacker;

					//Initialize:
					SetCopCuffs(Attacker, (GetCopCuffs(Attacker) + 1));

					SetCopExperience(Attacker, (GetCopExperience(Attacker) + 1));

					//Check:
					if(HadBounty > 0)
					{

						//Initialize:
						SetCopExperience(Attacker, (GetCopExperience(Attacker) + 3));

						//AddCash:
						int AddCash = 1000;

						//Check:
						if(GetBank(Client) - AddCash > 0)
						{

							//Initulize:
							SetBank(Client, (GetBank(Client) - AddCash));
						}

						//Initulize:
						SetBank(Attacker, (GetBank(Attacker) + AddCash));

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You're cuffed by \x0732CD32%N\x07FFFFFF. You are also fined €\x0732CD32%i\x07FFFFFF!", Attacker, AddCash);

						CPrintToChat(Attacker, "\x07FF4040|RP|\x07FFFFFF - You cuffed \x0732CD32%N!\x07FFFFFF, and Earned €\x0732CD32%i", Client, AddCash);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You're cuffed by \x0732CD32%N!", Attacker);

						CPrintToChat(Attacker, "\x07FF4040|RP|\x07FFFFFF - You cuffed \x0732CD32%N!", Client);
					}

					//Check:
					if(IsCuffDamageDisabled() == 1)
					{

						//Initialize:
						Damage = 0.0;
					}
				}
			}

			//Override:
			else
			{

				//Not In Distance:
				if(GetCrime(Client) > 500 && IsCuffed(Client))
				{

					//Print:
					CPrintToChat(Attacker, "\x07FF4040|RP|\x07FFFFFF - You hit a criminal.");
				}
			}
				
			//Initialize:
			Damage = 0.0;
		}
	}

	//Check:
	if(IsCop(Client) && IsCop(Attacker) && IsCopKillDisabled() == 1)
	{
		
		//Initialize:
		Damage = 0.0;
	}
}

public Action OnClientCuffCheckInVehicle(int Client, int Vehicle, int Attacker, float &Damage)
{

	//Declare:
	char WeaponName[32];

	//Initulize;
	GetClientWeapon(Attacker, WeaponName, sizeof(WeaponName));

	//Is Stun Stick:
	if(StrEqual(WeaponName, GetArrestWeapon(), false))
	{

		//Is Cop:
		if((!IsCop(Client) && IsCop(Attacker)) || IsAdmin(Attacker))
		{

			//Declare:
			float CopOrigin[3];
			float Position[3];

			//Get Prop Data:
			GetEntPropVector(Vehicle, Prop_Send, "m_vecOrigin", Position);

			GetClientAbsOrigin(Attacker, CopOrigin);

			//Declare:
			float Dist = GetVectorDistance(Position, CopOrigin);

			//In Distance:	
			if(Dist <= 150)
			{

				//Is Client Cuffed:
				if(IsCopUnCuffDisabled() == 0 && IsCuffed(Client) && (IsCop(Attacker) || IsAdmin(Attacker)))
				{

					//UnCuff Client:
					UnCuff(Client);

					//Print:
					CPrintToChat(Attacker, "\x07FF4040|RP|\x07FFFFFF - You uncuff \x0732CD32%N\x07FFFFFF!", Client);

					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You're uncuffed by \x0732CD32%N\x07FFFFFF.", Attacker);

					//Check:
					if(IsCuffDamageDisabled() == 1)
					{

						//Initialize:
						Damage = 0.0;
					}
				}

				//Is Client Cuffed:
				else if(IsCopUnCuffDisabled() == 1 && IsCuffed(Client) && IsAdmin(Attacker))
				{

					//UnCuff Client:
					UnCuff(Client);

					//Print:
					CPrintToChat(Attacker, "\x07FF4040|RP|\x07FFFFFF - You uncuff \x0732CD32%N\x07FFFFFF!", Client);

					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You're uncuffed by \x0732CD32%N\x07FFFFFF.", Attacker);

					//Check:
					if(IsCuffDamageDisabled() == 1)
					{

						//Initialize:
						Damage = 0.0;
					}
				}

				//Is Not Cuffed + Has Crime:
				else if(GetCrime(Client) > 2500)
				{

					//Exit:
					ExitVehicle(Client, Vehicle, true);

					//Initulize:
					OnPlayerCuffGangCheck(Client, Attacker);

					//Declare:
					int HadBounty = GetBounty(Client);

					//Cuff Player:
					Cuff(Client);

					//Jail Time:
					CalculateJail(Client);

					//Initialize:
					SetCrime(Client, 0);

					SetBounty(Client, 0);

					WhoCuffed[Client] = Attacker;

					//Initialize:
					SetCopCuffs(Attacker, (GetCopCuffs(Attacker) + 1));

					SetCopExperience(Attacker, (GetCopExperience(Attacker) + 1));

					//Check:
					if(HadBounty > 0)
					{

						//Initialize:
						SetCopExperience(Attacker, (GetCopExperience(Attacker) + 3));

						//AddCash:
						int AddCash = 1000;

						//Check:
						if(GetBank(Client) - AddCash > 0)
						{

							//Initulize:
							SetBank(Client, (GetBank(Client) - AddCash));
						}

						//Initulize:
						SetBank(Attacker, (GetBank(Attacker) + AddCash));

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You're cuffed by \x0732CD32%N\x07FFFFFF. You are also fined €\x0732CD32%i\x07FFFFFF!", Attacker, AddCash);

						CPrintToChat(Attacker, "\x07FF4040|RP|\x07FFFFFF - You cuffed \x0732CD32%N!\x07FFFFFF, and Earned €\x0732CD32%i", Client, AddCash);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You're cuffed by \x0732CD32%N!", Attacker);

						CPrintToChat(Attacker, "\x07FF4040|RP|\x07FFFFFF - You cuffed \x0732CD32%N!", Client);
					}

					//Check:
					if(IsCuffDamageDisabled() == 1)
					{

						//Initialize:
						Damage = 0.0;
					}

				}
			}

			//Override:
			else
			{

				//Not In Distance:
				if(GetCrime(Client) > 500 && IsCuffed(Client))
				{

					//Print:
					CPrintToChat(Attacker, "\x07FF4040|RP|\x07FFFFFF - You hit a criminal.");
				}
			}
				
			//Initialize:
			Damage = 0.0;
		}
	}
}

public Action OnPlayerGrab(int Client, int Player)
{

	//Declare:
	float ClientOrigin[3];
	float OtherOrigin[3];

	//Initialize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

	GetEntPropVector(Player, Prop_Send, "m_vecOrigin", OtherOrigin);

	//Declare:
	float Dist = GetVectorDistance(ClientOrigin, OtherOrigin);

	//In Distance:
	if(Dist <= 500)
	{

		//Is In Time:
		if(GetLastPressedE(Client) > (GetGameTime() - 1.5))
		{

			//Not Grabbed:
			if(GetGrabbed(Client) == -1)
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Grabbed \x0732CD32%N\x07FFFFFF.", Player);

				CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Grabbed you.", Client);

				//Initialize:
				SetGrabbed(Client, Player);

				//Timer:
				CreateTimer(0.1, Pusher, Client);

				//Set Speed:
				SetEntitySpeed(Player, 1.0);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You let go \x0732CD32%N\x07FFFFFF.", Player);

				CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF let you go.", Client);

				//Initialize:
				SetGrabbed(Client, -1);
		
				//Set Speed:
				SetEntitySpeed(Player, 0.4);
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Grab \x0732CD32%N\x07FFFFFF!", Player);

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

//Police Catcher
public Action Pusher(Handle Timer, any Client)
{

	//Declare:
	int Ent = Grabbing[Client];

	//Is Grabbed:
	if(Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent) && IsPlayerAlive(Ent))
	{

		//Declare:
		float ClientOrigin[3];
		float EntOrigin[3];

		//Initialize:
		GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", EntOrigin);

		//Declare:
		float Dist = GetVectorDistance(ClientOrigin, EntOrigin);

		//In Distance:
		if(Dist <= 75)
		{

			//Timer:
			CreateTimer(0.2, Pusher, Client);
		}

		//To Far:
		else if(Dist <= 500 && Dist > 100)
		{

			//Declare:
			float Pull[3];

			//Caclulate:
	    		GetPullBetweenEntities(Client, Ent, 3.0, Pull);

			//Teleport:
			TeleportEntity(Ent, NULL_VECTOR, NULL_VECTOR, Pull);

			//Timer:
			CreateTimer(0.1, Pusher, Client);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You lost \x0732CD32%N\x07FFFFFF!", Ent);

			CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF lost you!", Client);

			//Set Speed:
			SetEntitySpeed(Ent, 0.4);

			//Initialize:
			Grabbing[Client] = -1;
		}
	}

	//Check:
	if(Ent > GetMaxClients() && IsValidEdict(Ent))
	{

		//Declare:
		float ClientOrigin[3];
		float OtherOrigin[3];

		//Initialize:
		GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", OtherOrigin);

		//Declare:
		float Dist = GetVectorDistance(ClientOrigin, OtherOrigin);

		//In Distance:
		if(Dist <= 75)
		{

			//Timer:
			CreateTimer(0.2, Pusher, Client);
		}

		//To Far:
		else if(Dist <= 500 && Dist > 100)
		{

			//Declare:
			float Pull[3];

			//Caclulate:
	    		GetPullBetweenEntities(Client, Ent, 3.0, Pull);

			//Teleport:
			TeleportEntity(Ent, NULL_VECTOR, NULL_VECTOR, Pull);

			//Timer:
			CreateTimer(0.1, Pusher, Client);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You lost \x0732CD32%i\x07FFFFFF!", Ent);

			//Initialize:
			Grabbing[Client] = -1;
		}
	}

	//Override:
	else
	{

		//Initialize:
		Grabbing[Client] = -1;
	}
}

public Action OnClientPushPlayer(int Client, int Player)
{

	//Declare:
	float ClientOrigin[3];
	float OtherOrigin[3];

	//Initialize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

	GetEntPropVector(Player, Prop_Send, "m_vecOrigin", OtherOrigin);

	//Declare:
	float Dist = GetVectorDistance(ClientOrigin, OtherOrigin);

	//In Distance:
	if(Dist <= 150)
	{

		//Is In Time:
		if(GetLastPressedE(Client) < (GetGameTime() - 1.5))
		{

			//Declare:
			float Push[3];

			//Initulize:
			GetPushBetweenEntities(Client, 500.0, Push);

			//Teleport:
			TeleportEntity(Player, NULL_VECTOR, NULL_VECTOR, Push);

			//Initulize:
			SetLastPressedE(Client, (GetGameTime() + 1.5));
		}

	}
}

public Action Command_UnCuff(int Client, int Args)
{

	//Is Valid:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_uncuff <name>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Uncuff Player:
	UnCuff(Player);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You uncuff \x0732CD32%N", Player);

	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - You are uncuffed by \x0732CD32%N", Client);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" uncuffed \"%L\"", Client, Player);
#endif
	//Return:
	return Plugin_Handled; 
}

public Action Command_Cuff(int Client, int Args)
{

	//Is Valid:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_cuff <name>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	SetPostCrime(Player, GetCrime(Player));

	WhoCuffed[Player] = Client;

	//Cuff Player:
	Cuff(Player);

	//Jail Time:
	CalculateJail(Player);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Got him. \x0732CD32%N\x07FFFFFF is now cuffed", Player);

	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - You are cuffed by \x0732CD32%N", Client);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" cuffed \"%L\"", Client, Player);
#endif
	//Return:
	return Plugin_Handled; 
}

public Action Command_SetExit(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Not Valid Charictor:
	if(Args > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter Usage: sm_setexit");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Origin[3];

	//Initialize:
	GetClientAbsOrigin(Client, Origin);

	//Declare:
	char query[512];
	char Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Spawn Already Created:
	if(ExitOrigin[0] == 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE Jail SET Position = '%s' WHERE Map = '%s' AND Id = %i;", Position, ServerMap(), EXITID);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO Jail (`Map`,`Id`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), EXITID, Position);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Loop:
	for(int X = 0; X < 3; X++)
	{

		//Initulize:
		ExitOrigin[X] = Origin[X];
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Jail Exit has been set to position (\x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF)", Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_SetVipJail(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Not Valid Charictor:
	if(Args > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter Usage: sm_vipjail");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Origin[3];

	//Initialize:
	GetClientAbsOrigin(Client, Origin);

	//Declare:
	char query[512];
	char Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Spawn Already Created:
	if(VIPOrigin[0] == 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE Jail SET Position = '%s' WHERE Map = '%s' AND Id = %i;", Position, ServerMap(), VIPID);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO Jail (`Map`,`Id`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), VIPID, Position);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Loop:
	for(int X = 0; X < 3; X++)
	{

		//Initulize:
		VIPOrigin[X] = Origin[X];
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - vip Jail has been set to position (\x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF)", Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_AddJail(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Not Valid Charictor:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter Usage: sm_addjail <ID>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Declare:
	int Var = StringToInt(Arg1);

	//Is Valid:
	if(Var > 30 || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter Usage: sm_addjail <Between 1 - %i>", 30);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Origin[3];

	//Initialize:
	GetClientAbsOrigin(Client, Origin);

	//Declare:
	char query[512];
	char Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Check:
	if(Var <= MAXJAILS)
	{

		//Spawn Already Created:
		if(JailSellOrigin[Var][0] != 69.0)
		{

			//Format:
			Format(query, sizeof(query), "UPDATE Jail SET Position = '%s' WHERE Map = '%s' AND Id = %i;", Position, ServerMap(), Var);
		}

		//Override:
		else
		{

			//Format:
			Format(query, sizeof(query), "INSERT INTO Jail (`Map`,`Id`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), Var, Position);
		}
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO Jail (`Map`,`Id`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), Var, Position);
	}
	
	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Check:
	if(Var <= MAXJAILS)
	{

		//Loop:
		for(int X = 0; X <= 2; X++) 
		{

			//Initulize:
			JailSellOrigin[Var][X] = Origin[X];
		}
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Jail %s has been set to position (\x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF)", Arg1, Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_SetSui(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Not Valid Charictor:
	if(Args > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter Usage: sm_setsuicide");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Origin[3];

	//Initialize:
	GetClientAbsOrigin(Client, Origin);

	//Declare:
	char query[512];
	char Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Spawn Already Created:
	if(ExecuteOrigin[0] == 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE Jail SET Position = '%s' WHERE Map = '%s' AND Id = %i;", Position, ServerMap(), EXECUTEID);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO Jail (`Map`,`Id`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), EXECUTEID, Position);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Loop:
	for(int X = 0; X < 3; X++)
	{

		//Initulize:
		ExecuteOrigin[X] = Origin[X];
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Suicide Chamber has been set to position (\x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF)", Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_SetFirePit(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Not Valid Charictor:
	if(Args > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter Usage: sm_setfirepit");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Origin[3];

	//Initialize:
	GetClientAbsOrigin(Client, Origin);

	//Declare:
	char query[512];
	char Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Spawn Already Created:
	if(FirePitOrigin[0] == 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE Jail SET Position = '%s' WHERE Map = '%s' AND Id = %i;", Position, ServerMap(), FIREPITID);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO Jail (`Map`,`Id`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), FIREPITID, Position);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Loop:
	for(int X = 0; X < 3; X++)
	{

		//Initulize:
		FirePitOrigin[X] = Origin[X];
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Fire Pit has been set to position (\x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF)", Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_SetJailOrigin(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Not Valid Charictor:
	if(Args > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter Usage: sm_setjailorigin");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Origin[3];

	//Initialize:
	GetClientAbsOrigin(Client, Origin);

	//Declare:
	char query[512];
	char Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Spawn Already Created:
	if(ExecuteOrigin[0] == 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE Jail SET Position = '%s' WHERE Map = '%s' AND Id = %i;", Position, ServerMap(), JAIL);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO Jail (`Map`,`Id`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), JAIL, Position);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Loop:
	for(int X = 0; X < 3; X++)
	{

		//Initulize:
		ExecuteOrigin[X] = Origin[X];
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Jail has been set to position (\x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF - \x0732CD32%f\x07FFFFFF)", Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_TeleportCopToJail(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!IsAdmin(Client) && !IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you dont have access to this command!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(TR_PointOutsideWorld(JailOrigin))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Jail Origin is outside of world!");

		//Return:
		return Plugin_Handled;
	}

	//Teleport:
	TeleportEntity(Client, JailOrigin, NULL_VECTOR, NULL_VECTOR);

	//Return:
	return Plugin_Handled;
}

public Action Command_Bribe(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check
	if(!IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "%s You are not cuffed!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Check
	if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "%s Cops Can't use this command!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "%s Usage: sm_bribe <Amount>", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!IsClientInJailSell(Client))
	{

		//Print:
		CPrintToChat(Client, "%s You are not in jail.", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg[32];

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	int Bribe = StringToInt(Arg);

	//Check:
	if(Bribe > GetBank(Client))
	{

		//Print:
		CPrintToChat(Client, "%s You dont have enough money to bribe the cop!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Bribe > GetBank(Client))
	{

		//Print:
		CPrintToChat(Client, "%s You dont have enough money to bribe the cop!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Bribe > 5000)
	{

		//Print:
		CPrintToChat(Client, "%s you have offered a to high of a bail out!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(WhoCuffed[Client] == -1 || !IsClientConnected(WhoCuffed[Client]) || !IsClientInGame(WhoCuffed[Client]))
	{

		//Print:
		CPrintToChat(Client, "%s No one has cuffed you!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!IsCop(WhoCuffed[Client]) && !IsAdmin(WhoCuffed[Client]))
	{

		//Print:
		CPrintToChat(Client, "%s The person that cuffed you is no longer a cop!", PREFIX);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	CopBribeMenu(Client, WhoCuffed[Client], Bribe);

	//Return:
	return Plugin_Handled;
}

public void CopBribeMenu(int Client, int Cop, int Amount)
{

	//Initulize::
	SetMenuTarget(Cop, Client);

	//Handle:
	Menu menu = CreateMenu(HandleCopBribe);

	//Title:
	menu.SetTitle("%N\nHas Requested a bail out of\n\nYour Answer...", Client);

	//Declare:
	char Bribe[32];

	//Format:
	Format(Bribe, sizeof(Bribe), "%i", Amount);

	//Declare:
	char Bribe2[32];

	//Format:
	Format(Bribe2, sizeof(Bribe2), "Accept (%s)", IntToMoney(Amount));

	//Menu Button:
	menu.AddItem(Bribe, Bribe2);

	menu.AddItem("0", "Do Not Accept!");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Cop, 30);
}

//PlayerMenu Handle:
public int HandleCopBribe(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Declare:
		int Ent = GetMenuTarget(Client);

		//Button Selected:
		if(Result != 0)
		{

			//Connected:
			if(Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Check:
				if(!IsCuffed(Ent))
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF is no longer cuffed!", Ent);
				}

				//Override:
				else
				{

					//Has Enough Cash:
					if(GetBank(Ent) >= Result)
					{

						//Initulize:
						SetBank(Client, (GetBank(Client) + Result));

						SetBank(Ent, (GetBank(Ent) - Result));

						//Set Menu State:
						BankState(Client, Result);

						//Uncuff Client:
						AutoFree(Ent);

						//Print:
						CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - You are released from jail!");

						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has took your offer of \x0732CD32€%i\x07FFFFFF!", Client, Result);

						//Play Sound:
						EmitSoundToClient(Ent, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - You don't have that much Cash with you!");
					}
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
			}
		}

		//Override
		else
		{

			//Connected:
			if(Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have turned down \x0732CD32%N\x07FFFFFF's offer!", Ent);

				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has turned down your offer!", Client);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_Cancel)
	{


		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your bribe amount of \x0732CD32%s\x07FFFFFF has expired.", IntToMoney(Result));
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return view_as<bool>(true);
}

public Action Command_ViewJailSpawns(int Client, int Args)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Jail WHERE Map = '%s';", ServerMap());

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadJailPrint, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public void T_DBLoadJailPrint(Handle owner, Handle hndl, const char[] error, any data)
{

	//Declare:
	int Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadJail: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Jail Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0;
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, sizeof(Buffer));

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Is Jail:
			if(X <= MAXJAILS)
			{

				//Initulize:
				PrintToConsole(Client, "Jail Sell Spawn <id #%i> Position <%f^%f^%f>", X, Position[0], Position[1], Position[2]); 
			}

			//Is Jail:
			if(X == EXITID)
			{

				//Initulize:
				PrintToConsole(Client, "Exit Spawn <id #%i> Position <%f^%f^%f>", X, Position[0], Position[1], Position[2]); 
			}

			//Is Jail:
			if(X == VIPID)
			{

				//Initulize:
				PrintToConsole(Client, "Vip Spawn <id #%i> Position <%f^%f^%f>", X, Position[0], Position[1], Position[2]); 
			}

			//Is Jail:
			if(X == EXECUTEID)
			{

				//Initulize:
				PrintToConsole(Client, "Execute Spawn <id #%i> Position <%f^%f^%f>", X, Position[0], Position[1], Position[2]); 
			}

			//Is Jail:
			if(X == FIREPITID)
			{

				//Initulize:
				PrintToConsole(Client, "Firepit Spawn <id #%i> Position <%f^%f^%f>", X, Position[0], Position[1], Position[2]); 
			}

			//Is Jail:
			if(X == JAIL)
			{

				//Initulize:
				PrintToConsole(Client, "Jail Spawn <id #%i> Position <%f^%f^%f>", X, Position[0], Position[1], Position[2]); 
			}
		}

		//Print:
		PrintToServer("|RP| - Jail Found!");
	}
}

public int GetJailTime(int Client)
{

	//Return:
	return view_as<int>(JailTime[Client]);
}

public void SetJailTime(int Client, int Amount)
{

	//Initulize:
	JailTime[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Jail = %i WHERE STEAMID = %i;", JailTime, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public int GetMaxJailTime(int Client)
{

	//Return:
	return view_as<int>(MaxJailTime[Client]);
}

public void SetMaxJailTime(int Client, int Amount)
{

	//Initulize:
	MaxJailTime[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET MaxJail = %i WHERE STEAMID = %i;", MaxJailTime[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public bool IsCuffed(int Client)
{

	//Return:
	return view_as<bool>(TimerExec[Client]);
}

public int GetGrabbed(int Client)
{

	//Return:
	return view_as<int>(Grabbing[Client]);
}

public void SetGrabbed(int Client, int Player)
{

	//Initulize:
	Grabbing[Client] = Player;
}

public int GetWhoCuffed(int Client)
{

	//Return:
	return view_as<int>(WhoCuffed[Client]);
}

public void SetWhoCuffed(int Client, int Player)
{

	//Initulize:
	WhoCuffed[Client] = Player;
}