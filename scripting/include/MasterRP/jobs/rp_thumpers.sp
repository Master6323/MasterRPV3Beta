//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_thumpers_included_
  #endinput
#endif
#define _rp_thumpers_included_

#if defined HL2DM

//Defines:
#define MAXTHUMPERS		10

//Combine Thumper:
int ThumperValue[MAXTHUMPERS + 1] = {0,...};
int ThumperEnt[MAXTHUMPERS + 1] = {-1,...};
int ThumperRob[MAXTHUMPERS + 1] = {0,...};
int Thumper[MAXPLAYERS + 1] = {-1,...};
int ThumperEffect[MAXTHUMPERS + 1] = {-1,...};

public void initThumpers()
{

	//Entity Event Hook:
	HookEntityOutput("prop_Thumper", "OnThumped", OnThumped);

	//Thumpers
	RegAdminCmd("sm_createthumper", Command_CreateThumper, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removethumper", Command_RemoveThumper, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listthumper", Command_ListThumpers, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipethumpers", Command_WipeThumpers, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbThumper);
}

public void initThumperRobbing()
{

	//Loop:
	for(int X = 0; X <= MAXTHUMPERS; X++)
	{

		//Is Valid:
		if(ThumperRob[X] > 0)
		{

			//Initulize:
			ThumperRob[X] -= 1;
		}

		//Check:
		if(IsValidEdict(ThumperEnt[X]))
		{

			//Initulize:
			ThumperEffect[X] += 1;

			//Check:
			if(ThumperEffect[X] >= 120)
			{

				//Check:
				if(ThumperValue[X] < 1000)
				{

					//Accept:
					AcceptEntityInput(ThumperEnt[X], "Enable");

					//Initulize:
					ThumperEffect[X] = 0;

					//Timer:
					CreateTimer(24.0, TurnOffThumper);
				}
			}
		}
	}
}

//Create Database:
public Action CreateSQLdbThumper(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Thumper`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NULL, `ThumperId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadThumper(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Thumper WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadThumper, query);
}

//Thumped Event:
public void OnThumped(const char[] Output, int Caller, int Activator, float Delay)
{

	//Is Valid:
	if(IsValidEdict(Caller))
	{

		//EntCheck:
		if(CheckMapEntityCount() < 2000)
		{

			//Declare:
			float Origin[3];

			//Get Prop Data:
			GetEntPropVector(Caller, Prop_Send, "m_vecOrigin", Origin);

			//Temp Ent:
			TE_SetupSparks(Origin, NULL_VECTOR, 5, 5);

			//Send:
			TE_SendToAll();
		}

		//Loop:
		for(int X = 0; X < MAXTHUMPERS; X++)
		{

			//Valid:
			if(ThumperEnt[X] == Caller && ThumperValue[X] < 1000)
			{

				//Declare:
				int AddValue = GetRandomInt(10, 15);

				//Too Much:
				if(ThumperValue[X] + AddValue > 1000)
				{

					//Initulize:
					ThumperValue[X] = 1000;

					//Accept:
					AcceptEntityInput(ThumperEnt[X], "Disable");
				}

				//Override:
				else
				{
					//Initulize:
					ThumperValue[X] += AddValue;
				}
			}
		}

	}
}

public Action TurnOffThumper(Handle Timer)
{

	//Loop:
	for(int X = 0; X < MAXTHUMPERS; X++)
	{

		//Valid:
		if(IsValidEdict(ThumperEnt[X]))
		{

			//Accept:
			AcceptEntityInput(ThumperEnt[X], "Disable");
		}
	}
}

//Create Thumper:
public Action Command_CreateThumper(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createthumper <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	char query[512];
	char Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Spawn Already Created:
	if(ThumperEnt[StringToInt(SpawnId)] > 0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE Thumper SET Position = '%s' WHERE Map = '%s' AND ThumperId = %i;", Position, ServerMap(), StringToInt(SpawnId));
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO Thumper (`Map`,`ThumperId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(SpawnId), Position);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Thumper \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Thumper:
public Action Command_RemoveThumper(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removethumper <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Spawn Already Created:
	if(!IsValidEdict(ThumperEnt[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM Thumper WHERE ThumperId = %i AND Map = '%s';", StringToInt(SpawnId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Thumper (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListThumpers(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Thumper List: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= 10 + 1; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM Thumper WHERE Map = '%s' AND ThumperId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintThumpers, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeThumpers(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Thumper List Wiped: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 1; X < MAXTHUMPERS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM Thumpers WHERE ThumperId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBLoadThumper(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadThumper: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Thumpers Found in DB!");

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
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Create Thumper:
			CreatePropThumper(Position, X);
		}

		//Print:
		PrintToServer("|RP| - Thumpers Found!");
	}
}

public void T_DBPrintThumpers(Handle owner, Handle hndl, const char[] error, any data)
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
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBPrintThumpers: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SpawnId = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", SpawnId, Buffer);
		}
	}
}

//damage = 0
//size = 200 CreatePropThumper(ent, Pos, 1, "220", "0.0");

public int CreatePropThumper(float Pos[3], int X)
{

	//Initulize::
	int Ent = CreateEntityByName("prop_Thumper");

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Declare:
		char SpawnOrg[50];

		//Format:
		Format(SpawnOrg, sizeof(SpawnOrg), "%f %f %f", Pos[0], Pos[1], Pos[2]);

		//Dispatch:
		DispatchKeyValue(Ent, "origin", SpawnOrg);

		DispatchKeyValue(Ent, "model", "models/props_combine/CombineThumper002.mdl");

		DispatchKeyValue(Ent, "dustscale", "5.0");

		//Spawn:
		DispatchSpawn(Ent);

		//Accept:
		AcceptEntityInput(Ent, "Enable");

		//Initulize:
		ThumperValue[X] = GetRandomInt(100, 200);

		ThumperEnt[X] = Ent;

		ThumperRob[X] = 0;

		//Return:
		return Ent;
	}

	//Return:
	return -1;
}

//Handle Use Forward:
public void OnThumperUse(int Client, int Ent)
{

	//Check:
	if(IsCop(Client) || IsAdmin(Client))
	{

		//Loop:
		for(int X = 0; X < MAXTHUMPERS; X++)
		{

			//Valid:
			if(ThumperEnt[X] == Ent)
			{

				//Is In Time:
				if(GetLastPressedE(Client) > (GetGameTime() - 1.5))
				{

					//Valid:
					if(ThumperValue[X] > 0)
					{

						//Has Energy:
						if(GetEnergy(Client) >= 100)
						{

							//Declare:
							int AddValue = ThumperValue[X];

							//Initulize:
							SetMetal(Client, (GetMetal(Client) + AddValue));

							ThumperValue[X] = 0;

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have collected \x0732CD32%i\x07FFFFFF Metal!", AddValue);

							//Initialize:
							SetEnergy(Client, (GetEnergy(Client) - 100));
						}

						//Override:
						else	
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Dont have enough energy to collect Metal!");
						}
					}

					//Override:
					else	
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Combine Thumper has Metal to collect!");
					}

					//Initulize:
					SetLastPressedE(Client, 0.0);
				}

				//Override:
				else	
				{

					//Declare:
					char FormatMessage[255];

					Format(FormatMessage, sizeof(FormatMessage), "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF to Collect \x0732CD32%i\x07FFFFFF Metal.", ThumperValue[X]);

					//Print:
					OverflowMessage(Client, FormatMessage);

					//Initulize:
					SetLastPressedE(Client, GetGameTime());
				}
			}
		}
	}
}

public Action BeginThumperRob(int Client, int Ent)
{

	//Is In Time:
	if(GetLastPressedE(Client) > GetGameTime() + 1.5)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32<<Shift>>\x07FFFFFF Again to rob this Thumper!");

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	//Override:
	else
	{

		//Cuffed:
		if(IsCuffed(Client))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are cuffed you can't rob!");

			//Return:
			return Plugin_Continue;
		}

		//In Critical:
		else if(GetIsCritical(Client))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are in Critical Health!");

			//Return:
			return Plugin_Continue;
		}

		//Is Robbing:
		else if(GetEnergy(Client) < 15)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have enough energy to rob this \x0732CD32%s\x07FFFFFF!", "Thumper");

			//Return:
			return Plugin_Continue;
		}

		//Is Cop:
		else if(IsCop(Client))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Prevent crime, do not start it!");

			//Return:
			return Plugin_Continue;
		}

		//Is Cop:
		if(IsValidEdict(Thumper[Client]))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are already robbing");

			//Return:
			return Plugin_Continue;
		}

		//Declare:
		int Id;

		//Loop:
		for(int X = 0; X < MAXTHUMPERS; X++)
		{

			//Valid:
			if(ThumperEnt[X] == Ent)
			{

				//Initulize:
				Id = X;

				//Too Much:
				if(ThumperValue[X] == 0)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - This Thumper doesn't have any Metal!");

					//Return:
					return Plugin_Continue;
				}
			}
		}

		//Ready:
		if(ThumperRob[Id] > 0)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - This \x0732CD32%s\x07FFFFFF has been robbed too recently, (\x0732CD32%i\x07FFFFFF) Seconds left!", "Thumper", ThumperRob[Id]);

			//Return:
			return Plugin_Continue;
		}

		//Override:
		else
		{

			//Initulize:
			SetEnergy(Client, (GetEnergy(Client) - 15));

			//Print:
			CPrintToChatAll("\x07FF4040|RP-Hack|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is Robbing a \x0732CD32%s\x07FFFFFF!", Client, "Thumper");

			Thumper[Client] = Ent;

			//Save:
			ThumperRob[Id] = GetRobTime(); //needs cvar

			//Add Crime:
			SetCrime(Client, (GetCrime(Client) + 150));

			//Timer:
			CreateTimer(1.0, BeginRobberyThumper, Client, TIMER_REPEAT);
		}

		//Initulize:
		SetLastPressedE(Client, 0.0);
	}

	//Return:
	return Plugin_Continue;
}

public Action BeginRobberyThumper(Handle Timer, any Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client) || !IsValidEdict(Thumper[Client]))
	{

		//Initulize:
		Thumper[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Position[3];

	//Declare:
	int Id;

	//Loop:
	for(int X = 0; X < MAXTHUMPERS; X++)
	{

		//Valid:
		if(ThumperEnt[X] == Thumper[Client])
		{

			//Initulize:
			GetEntPropVector(Thumper[Client], Prop_Send, "m_vecOrigin", Position);

			Id = X;

			//Too Much:
			if(ThumperValue[X] == 0)
			{

				//Print:
				CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF Stopped robbing an NPC!", Client);

				//Initulize:
				Thumper[Client] = -1;

				//Return:
				return Plugin_Continue;
			}

			//Stop:
			break;
		}
	}

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	float Dist = GetVectorDistance(Position, ClientOrigin);

	//Too Far Away:
	if(Dist >= 250)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize:
		Thumper[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Random;

	//Is Valid:
	if(StrContains(GetJob(Client), "Street Thug", false) != -1 || IsAdmin(Client))
	{

		//Initulize:
		Random = GetRandomInt(5, 10);
	}

	//Override:
	else
	{

		//Initulize:
		Random = GetRandomInt(2, 5);
	}

	//Initulize:
	if(ThumperValue[Id] - Random <= 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize:
		Thumper[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(ThumperRob[Id] - Random <= 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize:
		SetMetal(Client, (GetMetal(Client) + Random));

		//Initulize:
		ThumperRob[Id] = 0;

		//Initulize:
		Thumper[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	ThumperRob[Id] -= Random;
	ThumperValue[Id] -= Random;

	//Initulize:
	SetMetal(Client, (GetMetal(Client) + Random));

	//Initialize:
	SetCrime(Client, (GetCrime(Client) + Random + Random));

	//Return:
	return Plugin_Handled;
}

public bool IsValidThumper(int Ent)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Door:
	if(StrEqual(ClassName, "Prop_Thumper"))
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public void ThumperHud(int Client, int Ent, float NoticeInterval)
{

	//Loop:
	for(int X = 0; X < MAXTHUMPERS; X++)
	{

		//Valid:
		if(ThumperEnt[X] == Ent)
		{

			//Declare:
			char FormatMessage[255];

			//Check:
			if(ThumperValue[X] == 0)
			{

				//Format:
				Format(FormatMessage, sizeof(FormatMessage), "Combine Thumper::\nMetal: Non Avaiable!");
			}

			//Override:
			else
			{

				//Format:
				Format(FormatMessage, sizeof(FormatMessage), "Combine Thumper:\nMetal: %i!", ThumperValue[X]);
			}

			//Declare:
			float Pos[2] = {-1.0, -0.805};
			int Color[4];

			//Initulize:
			Color[0] = GetEntityHudColor(Client, 0);
			Color[1] = GetEntityHudColor(Client, 1);
			Color[2] = GetEntityHudColor(Client, 2);
			Color[3] = 255;

			//Check:
			if(GetGame() == 2 || GetGame() == 3)
			{

				//Show Hud Text:
				CSGOShowHudTextEx(Client, 1, Pos, Color, Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
			}

			//Override:
			else
			{

				//Show Hud Text:
				ShowHudTextEx(Client, 1, Pos, Color, (NoticeInterval + 0.05), 0, 6.0, 0.0, (NoticeInterval), FormatMessage);
			}
		}
	}
}

public bool IsClientRobbingThumper(int Client)
{

	//Check:
	if(Thumper[Client] > 0)
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}
#endif