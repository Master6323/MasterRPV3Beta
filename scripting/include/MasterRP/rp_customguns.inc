#if defined _CustomGuns_included
	#endinput
#endif
#define _CustomGuns_included
#include <customguns/activity_list_new>
#include <customguns/const>
#include <customguns/stocks>

/**
 * Main forward for handling custom weapons
 * Called when client is pressing primary attack button and the weapon is ready to fire
 * If this is custom-type weapon, this will be called repeatedly until the next attack is delayed (eg. by calling CG_PlayPrimaryAttack) 
 *
 * @param client			client index
 * @param weapon			weapon entity index
 */
forward void CG_OnPrimaryAttack(int client, int weapon);

/**
 * Main forward for handling custom weapons
 * Called when client is pressing secondary attack button and the weapon is ready to fire
 * If this is custom-type weapon, this will be called repeatedly until the next attack is delayed (eg. by calling CG_PlaySecondaryAttack) 
 *
 * @param client			client index
 * @param weapon			weapon entity index
 */
forward void CG_OnSecondaryAttack(int client, int weapon);

/**
 * Weapon's "think" forward
 *
 * @param client			client index
 * @param weapon			weapon entity index
 */
forward void CG_ItemPostFrame(int client, int weapon);

/**
 * Called when weapon is being holstered. Useful for variable resets, sound stops, etc.
 *
 * @param client			client index
 * @param weapon			weapon entity index being holstered
 * @param switchingTo		weapon entity index player is switching to or -1
 */
forward void CG_OnReload(int client, int weapon, int Sucess);

/**
 * Gets weapon shoot position of client
 *
 * @param client			client index
 * @param pos				return position vector
 */
native void CG_GetShootPosition(int client, float pos[3], float forwardOffset = 0.0, float rightOffset = 0.0, float upOffset = 0.0);

/**
 * @return					disable client reload
 */
native bool CG_CanCloentReload(int client);

/**
 * @return					Set disable client reload
 */
native void CG_SetCanClientReload(int client, int Selected);
/**
 * Adds a weapon to player's inventory
 *
 * @param client			client index
 * @param classname			weapon classname
 * @param ignoreAdminLevel	if true, won't check if user is allowed to own this weapon
 *
 * @return					true if succeeded
 */
native bool CG_GiveGun(int client, const char[] classname, bool ignoreAdminLevel = false);

/**
 * Spawns a custom weapon by classname at location
 *
 * @param classname			weapon classname
 * @param origin			location
 *
 * @return					entity index or -1
 */
native int CG_SpawnGun(const char[] classname, float[3] origin);

/**
 * Clears player's inventory
 *
 * @param client			client index
 *
 */
native void CG_ClearInventory(int client);

/**
 * Check to see if a player has a weapon in there inventory
 *
 * @param client			client index
 * @param ClassName			weapon classname of whitch you want to search for
 *
 */
native bool CG_HasInInventory(int Client, const char[] ClassName);


/**
 * Plays an activity of choice, the weapon must support such activity
 * Supported activities of particular weapon model can be viewed in HLMV or Hammer
 * Does NOT set time of next attacks
 *
 * @param weapon			weapon entity index
 * @param activity			Activity supported by the viewmodel of the weapon, selected from activity_list include file
 *
 * @return					sequence duration
 */
native float CG_PlayActivity(int weapon, Activity activity);


/**
 * Plays ACT_VM_PRIMARYATTACK on the weapon and delays the next attack with the sequence duration
 *
 * @param weapon			weapon entity index
 *
 * @return					sequence duration
 */
native float CG_PlayPrimaryAttack(int weapon);

/**
 * Plays ACT_VM_SECONDARYATTACK on the weapon and delays the next attack with the sequence duration
 *
 * @param weapon			weapon entity index
 *
 * @return					sequence duration
 */
native float CG_PlaySecondaryAttack(int weapon);

/**
 * Plays animation on the player's model f.e. PLAYER_ATTACK1 or PLAYER_RELOAD
 *
 * @param client			client index
 * @param playerAnim		one of PLAYER_ANIM values (see const.inc)
 *
 */
native void CG_SetPlayerAnimation(int client, PLAYER_ANIM playerAnim);

/**
 * Removes player's ammo of specified weapon's ammo type
 * (for custom weapons with keep_ammo)
 *
 * @param client			client index
 * @param weapon			weapon entity index
 * @param count				ammo count to remove
 *
 */
native void CG_RemovePlayerAmmo(int client, int weapon, int count = 1);

/**
 * Does radius damage
 *
 */
native void CG_RadiusDamage(int inflictor, int attacker, float dmg, int dmgType, int weapon, const float origin[3], float radius, int ignoreEntity = -1);


/**
 * Delays both attacks by specified amount of time, allowing the weapon to 'cooldown' until it can be fired again
 *
 * @param weapon			weapon entity index
 * @param length			duration of cooldown
 *
 */
stock void CG_Cooldown(int weapon, float length){
	float CG_nextAttack = GetGameTime() + length;
	CG_SetNextPrimaryAttack(weapon, CG_nextAttack);
	CG_SetNextSecondaryAttack(weapon, CG_nextAttack);
}

stock void CG_SetNextPrimaryAttack(int weapon, float time){
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", time)
}

stock void CG_SetNextSecondaryAttack(int weapon, float time){
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", time)
}

//
//	See Stocks file for more functions!
//