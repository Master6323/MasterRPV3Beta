//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_weaponmod_included_
  #endinput
#endif
#define _rp_weaponmod_included_

#define MAXWEAPONS		128

//Roleplay Core:
char WeaponModPath[256];
char CPlayer[255];

//Drop Weapon Mod:
bool WeaponEq[MAXPLAYERS + 1] = {false,...};
int WeaponsOnMap[MAXWEAPONS + 1] = {-1,...};
Handle OnPhysGunDropItem[2047] = {INVALID_HANDLE,...};
int WeaponOffset = -1;

public void initWeaponMod()
{
#if defined HL2DM
	WeaponModPath = "data/roleplay/weaponmod/hl2dm.txt";
#endif
#if defined CSS
	WeaponModPath = "data/roleplay/weaponmod/css.txt";
#endif
#if defined CSGO
	WeaponModPath = "data/roleplay/weaponmod/csgo.txt";
#endif
#if defined TF2
	WeaponModPath = "data/roleplay/weaponmod/tf2.txt";
#endif
#if defined TF2BETA
	WeaponModPath = "data/roleplay/weaponmod/tf2beta.txt";
#endif
#if defined L4D
	WeaponModPath = "data/roleplay/weaponmod/l4d.txt";
#endif
#if defined L4D2
	WeaponModPath = "data/roleplay/weaponmodl4d2.txt";
#endif
	//Weapon Mod:
	BuildPath(Path_SM, WeaponModPath, 256, WeaponModPath);
	if(FileExists(WeaponModPath) == false) SetFailState("[SM] ERROR: Missing file '%s'", WeaponModPath);

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Declare:
	char Id[32];

	//Initulize:
	IntToString(GetGame(), Id, sizeof(Id));

	//Load:
	LoadString(Vault, Id, "CPlayer", "null", CPlayer);

	//Check:
	if(StrEqual(CPlayer, "null"))
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset! 'CPlayer'");
	}

	//Close:
	CloseHandle(Vault);
#if defined HL2DM
	//Handle:
	Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Declare:
	char Id2[255];
	char Path[32];
	char Buffer[255];

	//Format:
	Format(Path, sizeof(Path), "Prop_Alpha");

	//Loop:
	for(int X = 0; X < 64; X++)
	{

		//Convert:
		IntToString(X, Id2, 255);

		//Load:
		LoadString(Vault, Path, Id2, "null", Buffer);

		//Is Valid:
		if(!StrEqual(Buffer, "null", false))	
		{

			HookEntityOutput(Buffer, "OnPlayerPickup", pickup);
			HookEntityOutput(Buffer, "OnPhysGunDrop", drop);
		}
	}
#endif
	//Find Offsets:
	WeaponOffset = FindSendPropInfo(CPlayer, "m_hMyWeapons");

	//Close:
	CloseHandle(Vault);
}

public void pickup(const char[] output, int caller, int activator, float delay)
{


	//Is Valid:
	if(OnPhysGunDropItem[caller] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(OnPhysGunDropItem[caller]);

		//Handle:
		OnPhysGunDropItem[caller] = INVALID_HANDLE;
	}

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(caller, ClassName, sizeof(ClassName));

	//Check:
	if(caller == GetGlobalAnomalyEnt())
	{

		//Forward to rp_anomalyzone.sp
		OnPlayerPickUpAnomaly(activator);
	}

	//Set Owner Before Spawn:

	SetEntPropEnt(caller, Prop_Data, "m_hOwnerEntity", activator);

	//Print:
	//PrintToServer("|RP| Caller %i, Activator %i", caller, activator);

	SetEntityRenderMode(caller, RENDER_TRANSALPHA);
	SetVariantInt(120);
	AcceptEntityInput(caller, "alpha");
}

public void drop(const char[] output, int caller, int activator, float delay)
{

	//Is Valid:
	if(OnPhysGunDropItem[caller] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(OnPhysGunDropItem[caller]);

		//Handle:
		OnPhysGunDropItem[caller] = INVALID_HANDLE;
	}

	//Handle:
	OnPhysGunDropItem[caller] = CreateTimer(0.15, OnPhysGunDropItemTimer, caller);
}

public Action OnPhysGunDropItemTimer(Handle Timer, any caller)
{

	//Is Valid:
	if(OnPhysGunDropItem[caller] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(OnPhysGunDropItem[caller]);

		//Handle:
		OnPhysGunDropItem[caller] = INVALID_HANDLE;
	}

	//Print:
	//PrintToServer("|RP| Caller %i", caller);

	if(IsValidEdict(caller))
	{

		SetVariantInt(255);
		AcceptEntityInput(caller, "alpha");

		//Initulize:
		SetEntPropEnt(caller, Prop_Data, "m_hOwnerEntity", -1);
	}
}

public void ResetWeaponsOnMapChange()
{

	//Loop:
	for(int X = 0; X <= MAXWEAPONS; X++)
	{

		//Initulize:
		WeaponsOnMap[X] = -1;
	}
}

public void RemoveWeaponsOnMap()
{

	//Loop:
	for(int X = 0; X <= MAXWEAPONS; X++)
	{

		//Check:
		if(IsValidEdict(WeaponsOnMap[X]))
		{

			//Request:
			RequestFrame(OnNextFrameKill, WeaponsOnMap[X]);
		}

		//Initulize:
		WeaponsOnMap[X] = -1;
	}
}

public int GetWeaponsOnMap()
{

	//Declare:
	int Result = 0;

	//Loop:
	for(int X = 0; X <= MAXWEAPONS; X++)
	{

		//Check:
		if(IsValidEdict(WeaponsOnMap[X]))
		{

			//Initulize:
			Result += 1;
		}
	}

	//Return:
	return Result;
}

public int GetWeaponsOnMapFreeSlot()
{

	//Declare:
	int Result = 0;

	//Loop:
	for(int X = 0; X <= MAXWEAPONS; X++)
	{

		//Check:
		if(WeaponsOnMap[X] == -1)
		{

			//Initulize:
			Result = X;
		}
	}

	//Return:
	return Result;
}


public bool IsValidPropWeapon(int Entity)
{

	//Declare:
	bool Result = false;

	//Loop:
	for(int X = 0; X <= MAXWEAPONS; X++)
	{

		//Check:
		if(WeaponsOnMap[X] == Entity)
		{

			//Initluze:
			Result = true;

		}
	}

	//Return:
	return Result;
}
public void OnWeaponsMapCheckDestroyed(int Entity)
{

	//Loop:
	for(int X = 0; X <= MAXWEAPONS; X++)
	{

		//Check:
		if(WeaponsOnMap[X] == Entity)
		{

			//Initulize:
			WeaponsOnMap[X] = -1;
		}
	}
}

//Spawn Timer:
public Action RemoveWeapon(int Ent)
{

	//Is Valid:
	if(IsValidEdict(Ent) && Ent > MaxClients)
	{

		//Request:
		RequestFrame(OnNextFrameKill, Ent);
	}

	//Return:
	return Plugin_Continue;
}

public int WeaponDrop(int Client, char ClientWeapon[32], int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Return:
		return -1;
	}

	//Declare:
	char Model[255];

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Load:
	LoadString(Vault, ClientWeapon, "Model", "null", Model);

	//Close:
	CloseHandle(Vault);

	//Check:
	if(StrEqual(Model, "null"))
	{

		//Print:
		//PrintToServer("|RP| - %N Invalid weapon %s model %s",Client , ClientWeapon, Model);

		//Return:
		return -1;
	}

	//WeaponsOnMapCheck:
	if(GetWeaponsOnMap() >= MAXWEAPONS)
	{

		//Print:
		//PrintToServer("|RP| - Too many weapons already spawned on the map", GetWeaponsOnMap());

		//Return:
		return -1;
	}

	//Declare:
	float Position[3];
  	float EyeAngles[3];
	float Push[3];

	//Initialize:
  	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	GetClientAbsOrigin(Client, Position);

	//Calculate:
	Push[0] = (350.0 * Cosine(DegToRad(EyeAngles[1])));
    	Push[1] = (350.0 * Sine(DegToRad(EyeAngles[1])));
    	Push[2] = (-25.0 * Sine(DegToRad(EyeAngles[0])));
	Position[2] += 25.0;

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Unable to drop weapon due to outside of world");

		//Return:
		return -1;
	}

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Is Ent
	if(IsValidEntity(Ent))
	{

		//Is Precached:
		if(!IsModelPrecached(Model))
		{

			//Precache:
			PrecacheModel(Model);
		}

		//Values:
		DispatchKeyValue(Ent, "model", Model);

		//Spawn:
		DispatchSpawn(Ent);

		//Declare:
		//int Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");

		//Set End Data:
		//SetEntData(Ent, Collision, 1, 1, true);

		//Push Ent:
		if(Var == 2)
		{

			//Teleport:
		    	TeleportEntity(Ent, Position, EyeAngles, Push);
		}

		//Static Ent:
		if(Var == 1)
		{

			//Teleport:
			TeleportEntity(Ent, Position, NULL_VECTOR, NULL_VECTOR);
		}

		int Slot = GetWeaponsOnMapFreeSlot();

		WeaponsOnMap[Slot] = Ent;

		//Set Prop ClassName
		SetEntityClassName(Ent, ClientWeapon);

		//Return:
		return Ent;
	}

	//Return:
	return -1;
}
public int GiveClientWeapon(int Client, const char[] Weapon)
{

	//Initulize:
	WeaponEq[Client] = true;

	//Give Weapon:
	int Ent = GivePlayerItem(Client, Weapon);

	//Initulize:
	WeaponEq[Client] = false;

	//Return
	return Ent;
}

//Remove Weapons:
public void RemoveWeaponsInstant(int Client)
{

	//Declare:
	int WeaponId = 0;
	int MaxGuns = 64;

	//Loop:
	for(int X = 0; X < MaxGuns; X = (X + 4))
	{

		//Initialize:
		WeaponId = GetEntDataEnt2(Client, WeaponOffset + X);

		//Valid:
		if(WeaponId > GetMaxClients() && IsValidEdict(WeaponId))
		{

			//Weapon:
			RemovePlayerItem(Client, WeaponId);

			//Request:
			RequestFrame(OnNextFrameKill, WeaponId);
		}
	}
#if defined HL2DM
	//Check:
	if(IsCustomGunsLoaded())
	{

		//Give Player Default Weapon:
		CG_ClearInventory(Client);
	}
#endif
	//Declare:
	char DefaultWeapon[255];

	//Initulize:
	GetDefaultWeapon(DefaultWeapon);

	//Give Weapon:
	GiveClientWeapon(Client, DefaultWeapon);
}

public void AddAmmo(int Client, const char[] Name, int Amount, int MaxAmmo)
{

	//Declare:
	int Ent = HasClientWeapon(Client, Name, 0);

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Declare:
		int offset_ammo = FindDataMapInfo(Client, "m_iAmmo");

		int iPrimary = GetEntProp(Ent, Prop_Data, "m_iPrimaryAmmoType");

		int iAmmo = offset_ammo + (iPrimary * 4);

		int CurrentAmmo = GetEntData(Client, iAmmo, 4);

		//Full Click
		if(iAmmo != MaxAmmo)
		{

			//Check
			if(CurrentAmmo + Amount > MaxAmmo)
			{

				//Set Ammo:
				SetEntData(Client, iAmmo, MaxAmmo, 4, true);
			}

			//Override:
			else
			{

				//Set Ammo:
				SetEntData(Client, iAmmo, CurrentAmmo + Amount, 4, true);
			}
		}
	}
}

public void AddAmmo2(int Client, const char[] Name, int Amount, int MaxAmmo)
{

	//Declare:
	int Ent = HasClientWeapon(Client, Name, 0);

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Declare:
		int offset_ammo = FindDataMapInfo(Client, "m_iAmmo");

		int iPrimary = GetEntProp(Ent, Prop_Data, "m_iSecondaryAmmoCount");

		int iAmmo = offset_ammo + (iPrimary * 4);

		int CurrentAmmo = GetEntData(Client, iAmmo, 4);

		//Full Click
		if(iAmmo != MaxAmmo)
		{

			//Check
			if(CurrentAmmo + Amount > MaxAmmo)
			{

				//Set Ammo:
				SetEntData(Client, iAmmo, MaxAmmo, 4, true);
			}

			//Override:
			else
			{

				//Set Ammo:
				SetEntData(Client, iAmmo, CurrentAmmo + Amount, 4, true);
			}
		}
	}
}

public int GetAmmo(int Client, const char[] Name)
{

	//Declare:
	int Ent = HasClientWeapon(Client, Name, 0);

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Declare:
		int offset_ammo = FindDataMapInfo(Client, "m_iAmmo");

		int iPrimary = GetEntProp(Ent, Prop_Data, "m_iPrimaryAmmoType");

		int iAmmo = offset_ammo + (iPrimary * 4);

		int CurrentAmmo = GetEntData(Client, iAmmo, 4);

		//Return:
		return CurrentAmmo;
	}

	//Return:
	return -1;
}

public bool IsAmmo(const char[] Name)
{

	//Check:
	if(StrContains(Name, "item_", false) != -1)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public int HasClientWeapon(int Client, const char[] WeaponName, int Value)
{

	if(Value == 1)
	{

		//Give Item:
		GiveClientWeapon(Client, WeaponName);
	}

	//Declare:
	int MaxGuns = 64;

	//Loop:
	for(int X = 0; X < MaxGuns; X = (X + 4))
	{

		//Declare:
		int WeaponId = GetEntDataEnt2(Client, GetWeaponOffset() + X);

		//Is Valid:
		if(WeaponId > 0)
		{

			//Declare:
			char ClassName[32];

			//Initialize:
			GetEdictClassname(WeaponId, ClassName, sizeof(ClassName));

			//Is Valid:
			if(StrEqual(ClassName, WeaponName))
			{

				//Return:
				return WeaponId;

			}
		}
	}

	//Return:
	return -1;
}

public Action OnWeaponUse(int Client, int Ent, const char[] ClientWeapon)
{

	//Declare:
	int ItemId = ConvertWeaponToItem(ClientWeapon);

	//Valid Ent:
	if(ItemId != -1)
	{

		//Save:
		SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) + 1));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You pick up a weapon (\x0732CD32%s\x07FFFFFF)!", GetItemName(ItemId));

		//Request:
		RequestFrame(OnNextFrameKill, Ent);
	}
}

public int ConvertWeaponToItem(const char[] Weapon)
{

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Get Value
	int ItemId = LoadInteger(Vault, Weapon, "ItemId", -1);

	//Close:
	CloseHandle(Vault);

	//Return:
	return ItemId;
}

//Items to Weapon Mod Forward:
public void OnItemsWeaponUse(int Client, int ItemId, int Amount, bool Print)
{

	//Has Client Got Same Weapon As Item:
	if(HasClientWeapon(Client, GetItemVar(ItemId), false) == -1 && !IsAmmo(GetItemVar(ItemId)))
	{

		//Handle:
		Handle Vault = CreateKeyValues("Vault");

		//Load:
		FileToKeyValues(Vault, WeaponModPath);

		//Get Value
		int IsCustomGuns = LoadInteger(Vault, GetItemVar(ItemId), "CustomGuns", 0);

		//Close:
		CloseHandle(Vault);

		//Check Is Custom Gun:
		if(IsCustomGuns == 1)
		{
#if defined HL2DM
			//Has Plugin Loaded
			if(!IsCustomGunsLoaded())
			{

				//Print:
				if(Print) CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Unable to spawn \x0732CD32%s\x07FFFFFF due to customguns plugin not loaded.", GetItemName(ItemId));
			}

			//Override:
			else
			{

				//Check:
				if(!CG_HasInInventory(Client, GetItemVar(ItemId)))
				{

					//Give Weapon:
					CG_GiveGun(Client, GetItemVar(ItemId), true);

					//Print:
					if(Print) CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You use \x0732CD32%s\x07FFFFFF. Press and hold 'R' to access Custom Gun Menu!", GetItemName(ItemId));
				}

				//Override:
				else
				{

					//Print:
					if(Print) CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You already own a \x0732CD32%s\x07FFFFFF.", GetItemName(ItemId));
				}
			}
#endif
		}

		//Override:
		else
		{

			//Give Weapon:
			GiveClientWeapon(Client, GetItemVar(ItemId));

			//Print:
			if(Print) CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You use \x0732CD32%s\x07FFFFFF.", GetItemName(ItemId));
		}

		//Initialize:
		SetItemAmount(Client, ItemId, (GetItemAmount(Client, ItemId) - Amount));

		//Save Item If Used:
		SaveItem(Client, ItemId, GetItemAmount(Client, ItemId));
	}

	//Override:
	else if(IsAmmo(GetItemVar(ItemId)) || StrEqual(GetItemVar(ItemId), "weapon_slam") || StrEqual(GetItemVar(ItemId), "weapon_frag"))
	{

		//Declare:
		int Used = 0;

		//Med Kit
		if(StrEqual(GetItemVar(ItemId), "item_healthkit"))
		{

			//Initialize:
			int ClientHp = GetClientHealth(Client);

			//Has Full HP
			if(ClientHp < 100)
			{

				//To Much Health:
				if((ClientHp + 25) > 100)
				{

					//Set Client Health:
					SetEntityHealth(Client, 100);
				}

				//Override:
				else
				{

					//Set Client Health:
					SetEntityHealth(Client, (ClientHp + 25));
				}

				//Initulize:
				Used = 1;
			}

			//Override:
			else
			{

				//Print:
				if(Print) CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use anymore \x0732CD32%s\x07FFFFFF as your hp is already full", GetItemName(ItemId));
			}
		}
#if defined HL2DM
		//Weapon Check:
		else if(StrEqual(GetItemVar(ItemId), "weapon_frag"))
		{

			//Declare:
			int Ammo = GetWeaponSpawnAmmo(GetItemVar(ItemId));

			int MaxAmmo = GetWeaponMaxAmmo(GetItemVar(ItemId));

			//Add Ammo:
			AddAmmo(Client, GetItemVar(ItemId), Ammo, MaxAmmo);

			//Initulize:
			Used = 1;
		}

		//Weapon Check:
		else if(StrEqual(GetItemVar(ItemId), "weapon_slam"))
		{

			//Declare:
			int Ammo = GetWeaponSpawnAmmo(GetItemVar(ItemId));

			int MaxAmmo = GetWeaponMaxAmmo(GetItemVar(ItemId));

			//Add Ammo:
			AddAmmo(Client, GetItemVar(ItemId), Ammo, MaxAmmo);

			//Initulize:
			Used = 1;
		}

		//Weapon Check:
		else if(StrEqual(GetItemVar(ItemId), "item_ammo_ar2_altfire"))
		{

			//Declare:
			int Ammo = GetWeaponSpawnAmmo(GetItemVar(ItemId));

			int MaxAmmo = GetWeaponMaxAmmo(GetItemVar(ItemId));

			//Add Ammo:
			AddAmmo2(Client, GetItemVar(ItemId), Ammo, MaxAmmo);

			//Initulize:
			Used = 1;
		}
#endif
		//Override:
		else
		{

			//Declare:
			char ClassName[32];
			char WeaponName[255];

			//Format:
			Format(ClassName, sizeof(ClassName), "%s", GetItemVar(ItemId));

			//Format:
			Format(WeaponName, sizeof(WeaponName), "%s", GetAmmoWeapon(ClassName));

			//Check:
			if(!StrEqual(WeaponName, "null"))
			{

				//Declare:
				int MaxAmmo = GetAmmoToWeaponMaxAmmo(WeaponName);

				int CurrentAmmo = GetAmmo(Client, WeaponName);

				//Client Already has Max Ammo:
				if(CurrentAmmo != MaxAmmo)
				{

					//Declare:
					int Ammo = GetWeaponAmmo(WeaponName);

					//Add Ammo:
					AddAmmo(Client, WeaponName, Ammo, MaxAmmo);

					//Print:
					//PrintToServer("|RP| - Client %N has been added %i Ammo to %s with a Max Ammo of %i and Current Ammo level is %i", Client, Ammo, WeaponName, MaxAmmo, CurrentAmmo);

					//Initulize:
					Used = 1;
				}

				//Override:
				else
				{

					//Print:
					if(Print) CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You already have Max Ammo!");

					//Initulize:
					Used = 2;
				}
			}
		}

		//Check Print:
		if(Used == 1)
		{

			//Print:
			if(Print) CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You use \x0732CD32%s\x07FFFFFF.", GetItemName(ItemId));

			//Initialize:
			SetItemAmount(Client, ItemId, (GetItemAmount(Client, ItemId) - Amount));

			//Save Item If Used:
			SaveItem(Client, ItemId, GetItemAmount(Client, ItemId));
		}

		//Check Print:
		if(Used == 0)
		{

			//Print:
			if(Print) CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use \x0732CD32%s\x07FFFFFF.", GetItemName(ItemId));
		}
	}

	//Override:
	else
	{

		//Print:
		if(Print) CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You already own a \x0732CD32%s\x07FFFFFF.", GetItemName(ItemId));
	}
}

public int GetWeaponOffset()
{

	//Return:
	return WeaponOffset;
}

public bool CanClientWeaponEquip(int Client)
{

	//Return:
	return WeaponEq[Client];
}

public void SetClientWeaponEquip(int Client, bool Result)
{

	//Initialize:
	WeaponEq[Client] = Result;
}

char GetCPlayer()
{

	//Return:
	return CPlayer;
}


public void SetEquipAmmo(int Client, int Weapon)
{

	//Is Valid:
	if(IsValidEdict(Weapon))
	{

		//Declare:
		char ClassName[32];

		//Initialize:
		GetEdictClassname(Weapon, ClassName, sizeof(ClassName));

		//Handle:
		Handle Vault = CreateKeyValues("Vault");

		//Load:
		FileToKeyValues(Vault, WeaponModPath);

		//Get Value
		int IsCustomGuns = LoadInteger(Vault, ClassName, "CustomGuns", 0);

		//Close:
		CloseHandle(Vault);

		//Check:
		if(IsCustomGuns == 0)
		{

			//Declare:
			int Amount = GetWeaponSpawnAmmo(ClassName);

			int MaxAmmo = GetWeaponMaxAmmo(ClassName);

			int offset_ammo = FindDataMapInfo(Client, "m_iAmmo");

			int iPrimary = GetEntProp(Weapon, Prop_Data, "m_iPrimaryAmmoType");

			int iAmmo = offset_ammo + (iPrimary * 4);

			//Full Click
			if(iAmmo != MaxAmmo)
			{

				//Check
				if(Amount > MaxAmmo)
				{

					//Set Ammo:
					SetEntData(Client, iAmmo, MaxAmmo, 4, true);
				}

				//Override:
				else
				{

					//Set Ammo:
					SetEntData(Client, iAmmo, Amount, 4, true);
				}
			}
		}
	}
}

public int GetWeaponSpawnAmmo(const char[] ClientWeapon)
{

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Get Value
	int SpawnAmmo = LoadInteger(Vault, ClientWeapon, "SpawnAmmo", -1);

	//Close:
	CloseHandle(Vault);

	//Return:
	return SpawnAmmo;
}

public int GetWeaponMaxAmmo(const char[] ClientWeapon)
{

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Get Value
	int MaxAmmo = LoadInteger(Vault, ClientWeapon, "MaxAmmo", -1);

	//Close:
	CloseHandle(Vault);

	//Return:
	return MaxAmmo;
}

char GetDefaultWeapon(char ClientWeapon[255])
{

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Load:
	LoadString(Vault, "default_weapon", "classname", "null", ClientWeapon);

	//Close:
	CloseHandle(Vault);

	//Return:
	return ClientWeapon;
}

char GetRepairWeapon(char ClientWeapon[255] = "null")
{

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Load:
	LoadString(Vault, "weapon_repair", "classname", "null", ClientWeapon);

	//Close:
	CloseHandle(Vault);

	//Return:
	return ClientWeapon;
}

char GetArrestWeapon(char ClientWeapon[255] = "null")
{

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Load:
	LoadString(Vault, "weapon_arrest", "classname", "null", ClientWeapon);

	//Close:
	CloseHandle(Vault);

	//Return:
	return ClientWeapon;
}

char GetAmmoWeapon(char AmmoName[32] = "null")
{

	//Declare:
	char WeaponName[255];

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Load:
	LoadString(Vault, AmmoName, "classname", "null", WeaponName);

	//Close:
	CloseHandle(Vault);

	//Return:
	return WeaponName;
}

public int GetWeaponAmmo(char AmmoName[255])
{

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Get Value
	int Ammo = LoadInteger(Vault, AmmoName, "SpawnAmmo", -1);

	//Close:
	CloseHandle(Vault);

	//Return:
	return Ammo;
}

public int GetAmmoToWeaponMaxAmmo(char AmmoName[255])
{

	//Handle:
	Handle Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, WeaponModPath);

	//Get Value
	int MaxAmmo = LoadInteger(Vault, AmmoName, "MaxAmmo", -1);

	//Close:
	CloseHandle(Vault);

	//Return:
	return MaxAmmo;
}

#if defined HL2DM
public bool GunLabSpawnWeapon(int Client, int Ent, int Random)
{

	//Declare:
	float Position[3];
	char Model[64];
	char Name[32];

	//Random:
	if(Random == -1) Random = GetRandomInt(1, 11);

	//Initialize:
	Model = "Null";

	//Is Weapon:
	if(Random == 1)
	{

		//Initialize:
		Model = "models/weapons/w_pistol.mdl";

		Name = "weapon_pistol";
	}

	//Is Weapon:
	if(Random == 2)
	{

		//Initialize:
		Model = "models/weapons/w_crowbar.mdl";

		Name = "Weapon_crowbar";
	}

	//Is Weapon:
	if(Random == 3)
	{

		//Initialize:
		Model = "models/weapons/w_grenade.mdl";

		Name = "weapon_frag";
	}

	//Is Weapon:
	if(Random == 4)
	{

		//Initialize:
		Model = "models/weapons/w_smg1.mdl";

		Name = "weapon_smg1";
	}

	//Is Weapon:
	if(Random == 5)
	{

		//Initialize:
		Model = "models/weapons/w_shotgun.mdl";

		Name = "weapon_shotgun";
	}

	//Is Weapon:
	if(Random == 6)
	{

		//Initialize:
		Model = "models/weapons/w_rocket_launcher.mdl";

		Name = "weapon_rpg";
	}

	//Is Weapon:
	if(Random == 7)
	{

		//Initialize:
		Model = "models/weapons/w_slam.mdl";

		Name = "weapon_slam";
	}

	//Is Weapon:
	if(Random == 8)
	{

		//Initialize:
		Model = "models/weapons/w_357.mdl";

		Name = "weapon_357";
	}

	//Is Weapon:
	if(Random == 9)
	{

		//Initialize:
		Model = "models/weapons/w_crossbow.mdl";

		Name = "weapon_crossbow";
	}

	//Is Weapon:
	if(Random == 10)
	{

		//Initialize:
		Model = "models/weapons/w_stunbaton.mdl";

		Name = "weapon_stunstick";
	}

	//Is Weapon:
	if(Random == 11)
	{

		//Initialize:
		Model = "models/weapons/w_irifle.mdl";

		Name = "weapon_ar2";
	}


	if(StrEqual(Model, "Null"))
	{

		//Return:
		return false;
	}

	//Declare:
	int Ent2 = CreateEntityByName("prop_physics_override");

	//Is Ent
	if(IsValidEntity(Ent2) && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Is Precached:
		if(!IsModelPrecached(Model))
		{

			//Precache:
			PrecacheModel(Model);
		}

		//Values:
		DispatchKeyValue(Ent2, "model", Model);

		//Spawn:
		DispatchSpawn(Ent2);

		//Initulize:
		GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Position);

		//Set Origin:
		Position[2] += 20.0;

		//Teleport:
		TeleportEntity(Ent2, Position, NULL_VECTOR, NULL_VECTOR);

		//Set Prop ClassName
		SetEntityClassName(Ent2, Name);

		//Return:
		return true;
	}

	//Return:
	return false;
}
#endif

char GetWeaponModPath()
{

	return WeaponModPath;
}
/*
public int SetWeaponColors(int Client, char WeaponName[], int R, int G, int B, int A)
{

	//Declare:
	int MaxGuns = 64;

	//Loop:
	for(int X = 0; X < MaxGuns; X = (X + 4))
	{

		//Declare:
		int WeaponId = GetEntDataEnt2(Client, GetWeaponOffset() + X);

		//Is Valid:
		if(WeaponId > 0)
		{

			//Declare:
			char ClassName[32];

			//Initialize:
			GetEdictClassname(WeaponId, ClassName, sizeof(ClassName));

			//Is Valid:
			if(StrEqual(ClassName, WeaponName))
			{

				SetEntityRenderColor(WeaponId, R, G, B, A);

				SetEntityRenderMode(WeaponId, RenderMode:1);

			}
		}
	}
}
*/