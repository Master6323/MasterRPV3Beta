//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_defaults_included_
  #endinput
#endif
#define _rp_defaults_included_

public Action OnClientConnectSetDefaults(int Client)
{

	//Misc:
	initDefaultBomb(Client);

	initDefaultFireBomb(Client);

	initDefaultMicrowave(Client);

	initDefaultPropaneTank(Client);

	initDefaultRice(Client);

	initDefaultShield(Client);

	initDefaultSmokeBomb(Client);

	initDefaultWaterBomb(Client);

	initDefaultPlasmaBomb(Client);

	//Energy:
	initDefaultBattery(Client);

	initDefaultBitCoinMine(Client);

	initDefaultGenerator(Client);

	initDefaultGunLab(Client);

	initDefaultPrinters(Client);

	//Plants:
	initDefaultPlants(Client);

	initDefaultSeeds(Client);

	initDefaultLamp(Client);

	initDefaultBong(Client);

	//Meth:
	initDefaultMeths(Client);

	initDefaultPhosphoruTank(Client);

	initDefaultSodiumTub(Client);

	initDefaultHcAcidTub(Client);

	initDefaultAcetoneCan(Client);

	//Pills:
	initDefaultPills(Client);

	initDefaultToulene(Client);

	initDefaultSAcidTub(Client);

	initDefaultAmmonia(Client);

	//CoCain:
	initDefaultCocain(Client);

	initDefaultErythroxylum(Client);

	initDefaultBenzocaine(Client);

	//init Default Player Drugs:
	initDefaultPlayerDrugs(Client);

	SetTalkZone(Client);

	SetTalkZoneDefStats(Client);

	initHudColor(Client);

	SetDefaultJob(Client);

	initDefaultFireExtinguisher(Client);

	//Remove Sleeping:
	ResetSleeping(Client);

	//Remove Sleeping:
	ResetCritical(Client);

	//Reset Client Keys:
	ResetKeys(Client);

	//Defaults:
	initRandomModel(Client);

	//Default Items to prevent bug:
	DefaultItems(Client);

	//Jetpack:
	initDefaultJetpack(Client);

	//Set Default Prospective:
	SetThirdPersonView(Client, false);

	//Set Default Wearables:
	SetViewWearables(Client, false);

	ViewDefaults(Client);

	//Initulize:
	SetMenuTarget(Client, -1);

	SetTargetPlayer(Client, -1);

	SetGangDefault(Client, "null");

	SetIsLoaded(Client, false);

	SetWhoCuffed(Client, -1);

	//Ignore Fake Clients
	if(!IsFakeClient(Client))

	{

		//Send Value:
		SendConVarValue(Client, GetCheatsConVar(), "0");
	}
}