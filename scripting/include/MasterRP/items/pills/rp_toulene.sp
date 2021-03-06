//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_toulene_included_
  #endinput
#endif
#define _rp_toulene_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Define:
#define MAXITEMSPAWN		10

//Toulene:
int  TouleneEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int TouleneHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float TouleneFuel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char TouleneModel[256] = "models/winningrook/gtav/meth/toulene/toulene.mdl";

public void initToulene()
{

	//Commands:
	RegAdminCmd("sm_testtoulene", Command_TestToulene, ADMFLAG_ROOT, "<Id> <Time> - Creates a Toulene");
}

public void initDefaultToulene(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		TouleneEnt[Client][X] = -1;

		TouleneHealth[Client][X] = 0;

		TouleneFuel[Client][X] = 0.0;
	}
}

public int GetTouleneIdFromEnt(int Ent)
{

	//Declare:
	int Result = -1;

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(int X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(TouleneEnt[i][X] == Ent)
				{

					//Initulize:
					Result = X;

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Result;
}

public int HasClientToulene(int Client, int Id)
{

	//Is Valid:
	if(TouleneEnt[Client][Id] > 0)
	{

		//Return:
		return TouleneEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetTouleneHealth(int Client, int Id)
{

	//Return:
	return TouleneHealth[Client][Id];
}

public void SetTouleneHealth(int Client, int Id, int Amount)
{

	//Initulize:
	TouleneHealth[Client][Id] = Amount;
}

public float GetTouleneFuel(int Client, int Id)
{

	//Return:
	return TouleneFuel[Client][Id];
}

public void SetTouleneFuel(int Client, int Id, float Amount)
{

	//Initulize:
	TouleneFuel[Client][Id] = Amount;
}

public void initTouleneTime()
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(int X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(IsValidEdict(TouleneEnt[i][X]))
				{

					//Check:
					if(TouleneHealth[i][X] <= 0 || TouleneFuel[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 24, X);

						//Remove:
						RemoveToulene(i, X);
					}
				}
			}
		}
	}
}

public void TouleneHud(int Client, int Ent, float NoticeInterval)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(int X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(TouleneEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Tub:\nToulene: %0.2fmL\nHealth: %i", TouleneFuel[i][X], TouleneHealth[i][X]);

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
	}
}

public void RemoveToulene(int Client, int X)
{

	//Initulize:
	TouleneHealth[Client][X] = 0;

	TouleneFuel[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(TouleneEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(TouleneEnt[Client][X]);
	}

	//Check
	if(IsValidEdict(TouleneEnt[Client][X]) && TouleneEnt[Client][X] > GetMaxClients())
	{

		//Request:
		RequestFrame(OnNextFrameKill, TouleneEnt[Client][X]);
	}

	//Inituze:
	TouleneEnt[Client][X] = -1;
}

public bool CreateToulene(int Client, int Id, float Fuel, int Health, float Position[3], float Angle[3], bool IsConnected)
{

	//Check:
	if(IsConnected == false)
	{

		//Declare:
		float ClientOrigin[3];
		float EyeAngles[3];

		//Initialize:
		GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

		//Initialize:
  		GetClientEyeAngles(Client, EyeAngles);

		//Initialize:
		Position[0] = (ClientOrigin[0] + (FloatMul(100.0, Cosine(DegToRad(EyeAngles[1])))));

		Position[1] = (ClientOrigin[1] + (FloatMul(100.0, Sine(DegToRad(EyeAngles[1])))));

		Position[2] = (ClientOrigin[2] + 10);

		Angle = EyeAngles;

		//Check:
		if(TR_PointOutsideWorld(Position))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Toulene|\x07FFFFFF - Unable to spawn Toulene due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Fuel);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 24, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Toulene|\x07FFFFFF - You have just spawned a Toulene!");
	}

	//Initulize:
	TouleneFuel[Client][Id] = Fuel;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	TouleneHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", TouleneModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	TouleneEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientToulene);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Toulene");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (TouleneHealth[Client][Id] / 2), (TouleneHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestToulene(int Client, int Args)
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
	if(Args < 3)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testtoulene <Id> <Fuel> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sFuel[32];
	char sHealth[32];
	int Id = 0;
	int Health = 0;
	float Fuel = 0.0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sFuel, sizeof(sFuel));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Fuel = StringToFloat(sFuel);

	Health = StringToInt(sHealth);

	if(TouleneEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Toulene with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Toulene %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create Toulene:
	CreateToulene(Client, Id, Fuel, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action OnItemsTouleneUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Toulene|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Toulene|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		int MaxSlots = 1;

		//Declare:
		float ClientOrigin[3];
		float EyeAngles[3];

		//Initulize:
		GetClientAbsOrigin(Client, ClientOrigin);

		GetClientEyeAngles(Client, EyeAngles);

		//Declare:
		int Ent = -1;
		float Position[3];

		//Loop:
		for(int Y = 1; Y <= MaxSlots; Y++)
		{

			//Initulize:
			Ent = HasClientToulene(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				float Fuel = StringToFloat(GetItemVar(ItemId));

				//Create Toulene:
				if(CreateToulene(Client, Y, Fuel, 500, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Stop:
					break;
				}
			}

			//Override:
			else
			{

				//Too Many:
				if(Y == MaxSlots)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Toulene|\x07FFFFFF - You already have too many Toulene, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);

					//Stop:
					break;
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientToulene(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(TouleneEnt[i][X] == Ent)
			{

				//Check:
				if(Ent2 > 0 && Ent2 <= GetMaxClients() && IsClientConnected(Ent2))
				{

					//Check:
					if(Ent2 == i)
					{

						//Declare:
						char WeaponName[32];

						//Initulize;
						GetClientWeapon(Ent2, WeaponName, sizeof(WeaponName));

						//Check:
						if(StrContains(WeaponName, GetRepairWeapon(), false) == 0)
						{

							//Initulize:
							if(TouleneHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								TouleneHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								TouleneHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (TouleneHealth[i][X] / 2), (TouleneHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientToulene(TouleneEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientToulene(TouleneEnt[i][X], Damage, Ent2);
					}
				}

				//stop:
				break;
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action DamageClientToulene(int Ent, float &Damage, int &Attacker)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(int X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(TouleneEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) TouleneHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (TouleneHealth[i][X] / 2), (TouleneHealth[i][X] / 2), 255);

					//Check:
					if(TouleneHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 24, X);

						//Remove:
						RemoveToulene(i, X);
					}

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public bool IsTouleneInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(TouleneEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, TouleneEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}