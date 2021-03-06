//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_printers_included_
  #endinput
#endif
#define _rp_printers_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Define:
#define MAXITEMSPAWN		10

//Printers:
int Printed[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int PrinterEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int PrinterPaper[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int PrinterLevel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int PrinterHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float PrinterInk[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

//char MasterPrinterModel[256] = "models/props_c17/consolebox01a.mdl";
//char PrinterModel[256] = "models/props_lab/reciever01a.mdl";

public void initPrinters()
{

	//Commands:
	RegAdminCmd("sm_testprinter", Command_TestPrinter, ADMFLAG_ROOT, "<Id> <Time> - Creates a printer");
}

public void initDefaultPrinters(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		PrinterEnt[Client][X] = -1;

		Printed[Client][X] = 0;

		PrinterInk[Client][X] = 0.0;

		PrinterPaper[Client][X] = 0;

		PrinterHealth[Client][X] = -1;

		PrinterLevel[Client][X] = -1;
	}
}

public int HasClientPrinter(int Client, int Id)
{

	//Is Valid:
	if(PrinterEnt[Client][Id] > 0)
	{

		//Return:
		return PrinterEnt[Client][Id];
	}

	//Return:
	return -1;
}

public float GetPrinterInk(int Client, int Id)
{

	//Return:
	return PrinterInk[Client][Id];
}

public void SetPrinterInk(int Client, int Id, float Amount)
{

	//Initulize:
	PrinterInk[Client][Id] = Amount;
}

public int GetPrinterPaper(int Client, int Id)
{

	//Return:
	return PrinterPaper[Client][Id];
}

public void SetPrinterPaper(int Client, int Id, int Amount)
{

	//Initulize:
	PrinterPaper[Client][Id] = Amount;
}

public int GetPrinterMoney(int Client, int Id)
{

	//Return:
	return Printed[Client][Id];
}

public int GetPrinterLevel(int Client, int Id)
{

	//Return:
	return PrinterLevel[Client][Id];
}

public int GetPrinterHealth(int Client, int Id)
{

	//Return:
	return PrinterHealth[Client][Id];
}

public void OnPrinterUse(int Client, int Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Is In Time:
		if(GetLastPressedE(Client) > (GetGameTime() - 1.5))
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
						if(PrinterEnt[i][X] == Ent)
						{

							//Declare:
							int Earns = Printed[i][X];

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 2, X);

								//Remove:
								RemovePrinter(i, X, true);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Printer|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Money Printer!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 2500));

								//Set Menu State:
								BankState(Client, 2500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You have just destroyed a Money Printer. reseaved €\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else if(Earns != 0)
							{

								//Initulize:
								Printed[i][X] = 0;

								SetCash(Client, (GetCash(Client) + Earns));

								//Set Menu State:
								CashState(Client, Earns);
							}

							//Has No Money:
							if(Earns == 0)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - This Money Printer hasn't printed any cash!");
							}

							//Is Client Own:
							else if(Client == i)
							{

								//Initulize:
								SetCrime(Client, (GetCrime(Client) + Earns));

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You have collected €\x0732CD32%i\x07FFFFFF from your Printer!", Earns);
							}

							//Override:
							else if(Client != i)
							{

								//Declare:
								int Level = PrinterLevel[i][X];

								//Basic Printer:
								if(Level == 1)
								{

									//Save:
									SaveItem(Client, 238, (GetItemAmount(Client, 238) + 1));
								}

								//Advanced Printer:
								else if(Level == 2)
								{

									//Save:
									SaveItem(Client, 239, (GetItemAmount(Client, 239) + 1));
								}

								//Master Printer:
								else if(Level == 3)
								{

									//Save:
									SaveItem(Client, 240, (GetItemAmount(Client, 240) + 1));
								}

								//Ultimate Printer:
								else if(Level == 4)
								{

									//Save:
									SaveItem(Client, 241, (GetItemAmount(Client, 241) + 1));
								}

								//Remove From DB:
								RemoveSpawnedItem(i, 2, X);

								//Remove:
								RemovePrinter(i, X, true);

								//Initulize:
								SetCrime(Client, (GetCrime(Client) + (Earns / 2)));
								SetCrime(Client, (GetCrime(Client) + 1000));

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Printer|\x07FFFFFF - %N has stolen your Money Printer!", Client);

								CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You have stolen a money printer!");
							}
						}
					}
				}
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Printers|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Printer!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public void initPrintTime()
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
				if(IsValidEdict(PrinterEnt[i][X]))
				{

					//Is Valid:
					if((StrContains(GetJob(i), "Counterfeiter", false) != -1 || StrContains(GetJob(i), "Crime Lord", false) != -1 || GetDonator(i) > 0 || IsAdmin(i)) && !GetIsPlayerAfk(i))
					{

						//Check:
						if(!CheckGeneratorToPrinter(i, X))
						{

							//Initulize:
							CheckBatteryToPrinter(i, X);
						}
					}

					//Declare:
					float EntOrigin[3];

					//Initialize:
					GetEntPropVector(PrinterEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Show CrimeHud:
					ShowIllegalItemToCops(EntOrigin);
				}
			}
		}
	}
}

//Check to see if the generator is in distance
public bool CheckGeneratorToPrinter(int Client, int Y)
{

	//Declare:
	int Ent = -1;

	//Switch:
	while ((Ent = FindEntityByClassname(Ent, "prop_Generator")) > 0)
	{

		//Check:
		if(IsInDistance(PrinterEnt[Client][Y], Ent))
		{

			//Declare:
			int Id = GetGeneratorIdFromEnt(Ent);

			//Check:
			if(GetGeneratorEnergy(Client, Id) - 0.10 > 0)
			{

				//Initulize:
				SetBatteryEnergy(Client, Id, (GetBatteryEnergy(Client, Id) - GetRandomFloat(0.10, 0.30)));

				//Declare:
				int Level = PrinterLevel[Client][Y];

				//Check:
				if(PrinterPaper[Client][Y] > 0 && PrinterInk[Client][Y] > 0.0 && Printed[Client][Y] < (Level * 25000))
				{

					//Declare:
					int Random = GetRandomInt(1, 5);

					//Valid:
					if(Random == 1)
					{

						//Check:
						if(PrinterInk[Client][Y] - float(Level / 10) > 0.0)
						{

							//Initulize:
							PrinterInk[Client][Y] -= float(Level) / 10;
						}

						//Override:
						else
						{

							//Initulize:
							PrinterInk[Client][Y] = 0.0;
						}

						//Check:
						if(PrinterPaper[Client][Y] - Level > 0)
						{

							//Initulize:
							PrinterPaper[Client][Y] -= Level;
						}

						//Override:
						else
						{

							//Initulize:
							PrinterPaper[Client][Y] = 0;
						}

						//Initulize:
						Random = (5 * Level);

						Printed[Client][Y] += Random;
					}

					//Random Spark:
					if(Random > 2)
					{

						//EntCheck:
						if(CheckMapEntityCount() < 2000)
						{

							//Declare:
							float EntOrigin[3];

							//Initialize:
							GetEntPropVector(PrinterEnt[Client][Y], Prop_Send, "m_vecOrigin", EntOrigin);

							//Temp Ent:
							TE_SetupSparks(EntOrigin, NULL_VECTOR, 5, 5);

							//Send:
							TE_SendToAll();
						}
					}
				}

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}

//Check to see if the Battery is in distance
public bool CheckBatteryToPrinter(int Client, int Y)
{

	//Declare:
	int Ent = -1;

	//Switch:
	while ((Ent = FindEntityByClassname(Ent, "prop_Battery")) > 0)
	{

		//Check:
		if(IsInDistance(PrinterEnt[Client][Y], Ent))
		{

			//Declare:
			int Id = GetBatteryIdFromEnt(Ent);

			//Check:
			if(GetBatteryEnergy(Client, Id) - 0.10 > 0)
			{

				//Initulize:
				SetBatteryEnergy(Client, Id, (GetBatteryEnergy(Client, Id) - GetRandomFloat(0.10, 0.30)));

				//Declare:
				int Level = PrinterLevel[Client][Y];

				//Check:
				if(PrinterPaper[Client][Y] > 0 && PrinterInk[Client][Y] > 0.0 && Printed[Client][Y] < (Level * 25000))
				{

					//Declare:
					int Random = GetRandomInt(1, 5);

					//Valid:
					if(Random == 1)
					{

						//Check:
						if(PrinterInk[Client][Y] - float(Level / 10) > 0.0)
						{

							//Initulize:
							PrinterInk[Client][Y] -= float(Level) / 10;
						}

						//Override:
						else
						{

							//Initulize:
							PrinterInk[Client][Y] = 0.0;
						}

						//Check:
						if(PrinterPaper[Client][Y] - Level > 0)
						{

							//Initulize:
							PrinterPaper[Client][Y] -= Level;
						}

						//Override:
						else
						{

							//Initulize:
							PrinterPaper[Client][Y] = 0;
						}

						//Initulize:
						Random = (5 * Level);

						Printed[Client][Y] += Random;
					}

					//Random Spark:
					if(Random > 2)
					{

						//EntCheck:
						if(CheckMapEntityCount() < 2000)
						{

							//Declare:
							float EntOrigin[3];

							//Initialize:
							GetEntPropVector(PrinterEnt[Client][Y], Prop_Send, "m_vecOrigin", EntOrigin);

							//Temp Ent:
							TE_SetupSparks(EntOrigin, NULL_VECTOR, 5, 5);

							//Send:
							TE_SendToAll();
						}
					}
				}

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}

public void PrinterHud(int Client, int Ent, float NoticeInterval)
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
				if(PrinterEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];
					int len = 0;

					//Is Valid:
					if(StrContains(GetJob(i), "Counterfeiter", false) != -1 || StrContains(GetJob(i), "Crime Lord", false) != -1 || GetDonator(i) > 0 || IsAdmin(i))
					{

						//Declare:
						int Level = PrinterLevel[i][X];

						//Basic Printer:
						if(Level == 1)
						{

							//Format:
							len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printer (Basic):\n");
						}

						//Advanced Printer:
						else if(Level == 2)
						{

							//Format:
							len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printer (Advanced):\n");
						}

						//Master Printer:
						else if(Level == 3)
						{

							//Format:
							len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printer (Master):\n");
						}

						//Ultimate Printer:
						else if(Level == 4)
						{

							//Format:
							len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printer (Ultimate):\n");
						}

						//Has Paper:
						if(PrinterPaper[i][X] > 0)
						{

							//Format:
							len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printing Paper: %i Sheets\n", PrinterPaper[i][X]);
						}

						//Override:
						else
						{

							//Format:
							len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printing Paper: No Sheets\n");
						}

						//Has Ink:
						if(PrinterInk[i][X] > 0)
						{

							//Format:
							len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printer Ink: %0.2fmL\n", PrinterInk[i][X]);
						}

						//Override:
						else
						{

							//Format:
							len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printer Ink: No Ink\n");
						}

						//Format:
						len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printed (€%i)\nHealth: %i", Printed[i][X], PrinterHealth[i][X]);

						if(GetIsPlayerAfk(i))
						{

							//Format:
							len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printing suspended\n");
						}
					}

					//Override:
					else
					{

						//Format:
						len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Printers:\nOwner is not Counterfeiter\nPrinted (€%i)\nHealth: %i", Printed[i][X], PrinterHealth[i][X]);
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
	}
}

public void RemovePrinter(int Client, int X, bool Result)
{

	//EntCheck:
	if(CheckMapEntityCount() < 2047 && Result && IsValidEdict(PrinterEnt[Client][X]))
	{

		//Declare:
		float PrinterOrigin[3];

		//Get Prop Data:
		GetEntPropVector(PrinterEnt[Client][X], Prop_Send, "m_vecOrigin", PrinterOrigin);

		//Temp Ent:
		TE_SetupSparks(PrinterOrigin, NULL_VECTOR, 5, 5);

		//Send:
		TE_SendToAll();

		//Temp Ent:
		TE_SetupExplosion(PrinterOrigin, Explode(), 5.0, 1, 0, 600, 5000);

		//Send:
		TE_SendToAll();
	}

	//Emit Sound:
	//EmitAmbientSound("ambient/explosions/explode_5.wav", PrinterOrigin, SNDLEVEL_RAIDSIREN);

	//Initulize:
	PrinterPaper[Client][X] = 0;

	PrinterInk[Client][X] = 0.0;

	PrinterHealth[Client][X] = 0;

	PrinterLevel[Client][X] = 0;

	Printed[Client][X] = 0;

	//Check
	if(IsValidEdict(PrinterEnt[Client][X]) && PrinterEnt[Client][X] > GetMaxClients())
	{

		//Request:
		RequestFrame(OnNextFrameKill, PrinterEnt[Client][X]);
	}

	//Inituze:
	PrinterEnt[Client][X] = -1;
}

public bool CreatePrinter(int Client, int X, int Value, float Ink, int Paper, int Level, int Health, float Position[3], float Angle[3], bool IsConnected)
{

	//Check
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
		Position[0] = (ClientOrigin[0] + (FloatMul(50.0, Cosine(DegToRad(EyeAngles[1])))));

		Position[1] = (ClientOrigin[1] + (FloatMul(50.0, Sine(DegToRad(EyeAngles[1])))));

		Position[2] = (ClientOrigin[2] + 10);

		Angle = EyeAngles;

		//Check:
		if(TR_PointOutsideWorld(Position))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - Unable to spawn Printer outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f^%i", Ink, Health);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 2, X, Value, Paper, Level, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You have just spawned a Money Printer!");
	}

	//Initulize:
	Printed[Client][X] = Value;

	PrinterPaper[Client][X] = Paper;

	PrinterInk[Client][X] = Ink;

	PrinterHealth[Client][X] = Health;

	PrinterLevel[Client][X] = Level;


	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	if(Level <= 2)
		DispatchKeyValue(Ent, "model", "models/props_lab/reciever01a.mdl");
	else
		DispatchKeyValue(Ent, "model", "models/props_c17/consolebox01a.mdl");

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	PrinterEnt[Client][X] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientPrinter);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Money_Printer");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (PrinterHealth[Client][X] / 2), (PrinterHealth[Client][X] / 2), 255);

	//Is Valid:
	if(StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestPrinter(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testprinter <Id> <Money> <Level>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sValue[32];
	char sLevel[32];
	int Id = 0;
	int Value = 0;
	int Level = 0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sValue, sizeof(sValue));

	GetCmdArg(3, sLevel, sizeof(sLevel));

	Id = StringToInt(sId);

	Value = StringToInt(sValue);

	Level = StringToInt(sLevel);

	if(PrinterEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money printer with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Printer %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//CreatePrinter
	CreatePrinter(Client, Id, Value, float(Level * 125), (Level * 1250), Level, 500, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsPrinterUse(int Client, int ItemId)
{

	//Is Cop:
	if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		int MaxSlots = 1;

		//Valid Job:
		if(StrContains(GetJob(Client), "Drug Lord", false) != -1)
		{

			//Initulize:
			MaxSlots = 1;
		}

		//Valid Job:
		if(StrContains(GetJob(Client), "Crime Lord", false) != -1)
		{

			//Initulize:
			MaxSlots = 2;
		}

		//Valid Job:
		if(StrContains(GetJob(Client), "God Father", false) != -1)
		{

			//Initulize:
			MaxSlots = 3;
		}

		//Valid Job:
		if(GetDonator(Client) > 0 || IsAdmin(Client))
		{

			//Initulize:
			MaxSlots = 5;
		}

		//Add Extra Slots:
		MaxSlots += GetItemAmount(Client, 304);

		//Check:
		if(MaxSlots > MAXITEMSPAWN)
		{

			//Initulize:
			MaxSlots = MAXITEMSPAWN;
		}

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
			Ent = HasClientPrinter(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn Printer:
				if(CreatePrinter(Client, Y, 0, (StringToFloat(GetItemVar(ItemId)) * 125), (StringToInt(GetItemVar(ItemId)) * 1250), StringToInt(GetItemVar(ItemId)), 500, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Initulize:
					SetCrime(Client, (GetCrime(Client) + StringToInt(GetItemVar(ItemId))));

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
					CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You already have too many Printers, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);

					//Stop:
					break;
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientPrinter(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(PrinterEnt[i][X] == Ent)
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
							if(PrinterHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								PrinterHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								PrinterHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (PrinterHealth[i][X] / 2), (PrinterHealth[i][X] / 2), 255);

							//Check:
							if(PrinterHealth[i][X] > 100)
							{

								//Declare:
								int TempEnt = GetEntAttatchedEffect(PrinterEnt[i][X], 1);

								//Check:
								if(IsValidEdict(TempEnt))
								{

									//Kill:
									AcceptEntityInput(TempEnt, "kill");

									//Initulize:
									SetEntAttatchedEffect(TempEnt, 1, -1);
								}
							}
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientPrinter(PrinterEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientPrinter(PrinterEnt[i][X], Damage, Ent2);
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

public Action DamageClientPrinter(int Ent, float &Damage, int &Attacker)
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
				if(PrinterEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) PrinterHealth[i][X] -= RoundFloat(Damage);

					//Check:
					if(PrinterHealth[i][X] > 0 && PrinterHealth[i][X] <= 100)
					{

						//Declare:
						int TempEnt = GetEntAttatchedEffect(PrinterEnt[i][X], 1);

						//Check:
						if(!IsValidEdict(TempEnt) && PrinterEnt[i][X] != -1)
						{

							//Explode:
							CreateExplosion(Attacker, PrinterEnt[i][X]);

							//Check:
							if(PrinterEnt[i][X] > 0)
							{

								//Initulize Effects:
								int Effect = CreateEnvFire(PrinterEnt[i][X], "null", "200", "700", "0", "Natural");

								SetEntAttatchedEffect(PrinterEnt[i][X], 1, Effect);
							}
						}
					}

					//Check:
					if(PrinterHealth[i][X] > 100)
					{

						//Declare:
						int TempEnt = GetEntAttatchedEffect(PrinterEnt[i][X], 1);

						//Check:
						if(IsValidEdict(TempEnt))
						{

							//Kill:
							AcceptEntityInput(TempEnt, "kill");

							//Initulize:
							SetEntAttatchedEffect(TempEnt, 1, -1);
						}
					}

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (PrinterHealth[i][X] / 2), (PrinterHealth[i][X] / 2), 255);

					//Check:
					if(PrinterHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 2, X);

						//Remove:
						RemovePrinter(i, X, true);
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

public bool IsPrinterInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(PrinterEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, PrinterEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}

