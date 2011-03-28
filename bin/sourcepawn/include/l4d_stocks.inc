/**
 * =============================================================================
 * Left 4 Dead Stocks Library (C)2011 Buster "Mr. Zero" Nielsen
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */

#if defined _l4d_stocks_included
 #endinput
#endif
#define _l4d_stocks_included

#include <sdktools>

#define L4D_SPAWNFLAG_CANSPAWN          (0 << 0)
#define L4D_SPAWNFLAG_DISABLED          (1 << 0)
#define L4D_SPAWNFLAG_WAITFORSURVIVORS  (1 << 1)
#define L4D_SPAWNFLAG_WAITFORFINALE     (1 << 2)
#define L4D_SPAWNFLAG_WAITFORTANKTODIE  (1 << 3)
#define L4D_SPAWNFLAG_SURVIVORESCAPED   (1 << 4)
#define L4D_SPAWNFLAG_DIRECTORTIMEOUT   (1 << 5)
#define L4D_SPAWNFLAG_WAITFORNEXTWAVE   (1 << 6)
#define L4D_SPAWNFLAG_CANBESEEN         (1 << 7)
#define L4D_SPAWNFLAG_TOOCLOSE          (1 << 8)
#define L4D_SPAWNFLAG_RESTRICTEDAREA    (1 << 9)
#define L4D_SPAWNFLAG_BLOCKED           (1 << 10)

enum L4DTeam
{
	L4DTeam_Unassigned = 0,
	L4DTeam_Spectator = 1,
	L4DTeam_Survivor = 2,
	L4DTeam_Infected = 3
}

enum L4DWeaponSlot
{
	L4DWeaponSlot_Primary = 0,
	L4DWeaponSlot_Secondary = 1,
	L4DWeaponSlot_Grenade = 2,
	L4DWeaponSlot_FirstAid = 3,
	L4DWeaponSlot_Pills = 4
}

enum L4DGlowType
{
	L4DGlow_NoGlow = 0,
	L4DGlow_OnUse,
	L4DGlow_OnLookAt,
	L4DGlow_Constant
}

enum L4D1ZombieClassType
{
	L4D1ZombieClass_Smoker = 1,
	L4D1ZombieClass_Boomer,
	L4D1ZombieClass_Hunter,
	L4D1ZombieClass_Witch,
	L4D1ZombieClass_Tank,
	L4D1ZombieClass_NotInfected
}

enum L4D2ZombieClassType
{
	L4D2ZombieClass_Smoker = 1,
	L4D2ZombieClass_Boomer,
	L4D2ZombieClass_Hunter,
	L4D2ZombieClass_Spitter,
	L4D2ZombieClass_Jockey,
	L4D2ZombieClass_Charger,
	L4D2ZombieClass_Witch,
	L4D2ZombieClass_Tank,
	L4D2ZombieClass_NotInfected
}

enum L4D2ResourceType
{
	L4D2Resource_Ping,
	L4D2Resource_Score,
	L4D2Resource_TankTickets,
	L4D2Resource_Deaths,
	L4D2Resource_MaxHealth,
	L4D2Resource_IsGhost,
	L4D2Resource_IsIncapacitated,
	L4D2Resource_WantsToPlay,
	L4D2Resource_ZombieClass,
	L4D2Resource_TankTickets2,
	L4D2Resource_SurvivalTopMedal
};

static const String:L4D2ResourceNames[L4D2ResourceType][] =
{
	"m_iPing",
	"m_iScore",
	"m_iTankTickets",
	"m_iDeaths",
	"m_maxHealth",
	"m_isGhost",
	"m_isIncapacitated",
	"m_wantsToPlay",
	"m_zombieClass",
	"m_tankTickets",
	"m_nSurvivalTopMedal"
};

/**
 * Returns zombie player L4D1 zombie class.
 *
 * @param client		Player's index.
 * @return				Current L4D1ZombieClassType of player.
 * @error				Invalid client index.
 */
stock L4D1ZombieClassType:L4D_GetPlayerL4D1ZombieClass(client)
{
	return L4D1ZombieClassType:GetEntProp(client, Prop_Send, "m_zombieClass");
}

/**
 * Set zombie player L4D1 zombie class.
 *
 * @param client		Player's index.
 * @param class			L4D1ZombieClassType class symbol.
 * @noreturn
 * @error				Invalid client index.
 */
stock L4D_SetPlayerL4D1ZombieClass(client, L4D1ZombieClassType:class)
{
	SetEntProp(client, Prop_Send, "m_zombieClass", _:class);
}

/**
 * Returns zombie player L4D2 zombie class.
 *
 * @param client		Player's index.
 * @return				Current L4D2ZombieClassType of player.
 * @error				Invalid client index.
 */
stock L4D2ZombieClass:L4D_GetPlayerL4D2ZombieClass(client)
{
	return L4D2ZombieClass:GetEntProp(client, Prop_Send, "m_zombieClass");
}

/**
 * Set zombie player L4D2 zombie class.
 *
 * @param client		Player's index.
 * @param class			L4D2ZombieClassType class symbol.
 * @noreturn
 * @error				Invalid client index.
 */
stock L4D_SetPlayerL4D2ZombieClass(client, L4D2ZombieClassType:class)
{
	SetEntProp(client, Prop_Send, "m_zombieClass", _:class);
}

/**
 * Returns ghost state of zombie player.
 *
 * @param client		Player index.
 * @return				True if player is ghost, false otherwise.
 * @error				Invalid client index.
 */
stock bool:L4D_IsPlayerGhost(client)
{
	return bool:GetEntProp(client, Prop_Send, "m_isGhost", 1);
}

/**
 * Sets ghost state of zombie player.
 *
 * @param client		Player index.
 * @param isGhost		Sets ghost status.
 * @noreturn
 * @error				Invalid client index.
 */
stock L4D_SetPlayerGhostState(client, bool:isGhost)
{
	SetEntProp(client, Prop_Send, "m_isGhost", isGhost, 1);
}

/**
 * Returns ghost spawn state of zombie player.
 *
 * @param client		Player index.
 * @return				Player's spawn state bits.
 * @error				Invalid client index.
 */
stock L4D_GetPlayerGhostSpawnState(client)
{
	return GetEntProp(client, Prop_Send, "m_ghostSpawnState");
}

/**
 * Set zombie player's ghost spawn state bits.
 *
 * Note: The game overwrites spawn state bits every frame.
 *
 * @param client		Player index.
 * @param bits			Ghost spawn state bits.
 * @noreturn
 * @error				Invalid client index.
 */
stock L4D_SetPlayerGhostSpawnState(client, bits)
{
	SetEntProp(client, Prop_Send, "m_ghostSpawnState", bits);
}

/**
 * Returns whether zombie player is culling.
 *
 * @param client		Player index.
 * @return				True if player is culling, false otherwise.
 */
stock L4D_IsPlayerCulling(client)
{
	return bool:GetEntProp(client, Prop_Send, "m_isCulling", 1);
}

/**
 * Set culling state of zombie player.
 *
 * @param client		Player index.
 * @param isCulling		Whether player is culling.
 * @noreturn
 * @error				Invalid client index.
 */
stock L4D_SetPlayerCullingState(client, bool:isCulling)
{
	SetEntProp(client, Prop_Send, "m_isCulling", isCulling, 1);
}

/**
 * Returns whether player is incapacitated.
 *
 * Note: A tank player will return true when in dying animation.
 *
 * @param client		Player index.
 * @return				True if incapacitated, false otherwise.
 * @error				Invalid client index.
 */
stock bool:L4D_IsPlayerIncapacitated(client)
{
	return bool:GetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
}

/**
 * Set player's incapacitated state.
 *
 * @param client		Player index.
 * @param isIncapacitated Whether the player is incapacitated.
 * @noreturn
 * @error				Invalid client index.
 */
stock L4D_SetPlayerIncapacitatedState(client, bool:isIncapacitated)
{
	SetEntProp(client, Prop_Send, "m_isIncapacitated", isIncapacitated, 1);
}

/**
 * Returns survivor player shove penalty.
 *
 * @param client		Player index.
 * @return				Current shove penalty of player.
 */
stock L4D_GetPlayerShovePenalty(client)
{
	return GetEntProp(client, Prop_Send, "m_iShovePenalty");
}

/**
 * Set survivor player shove penalty.
 *
 * @param client		Player index.
 * @param shovePenalty	Shove penalty.
 * @noreturn
 * @error				Invalid client index.
 */
stock L4D_SetPlayerShovePenalty(client, shovePenalty)
{
	SetEntProp(client, Prop_Send, "m_iShovePenalty", shovePenalty);
}

/**
 * Returns tank player's frustration.
 *
 * @param client		Player index.
 * @return				How frustrated tank player is.
 * @error				Invalid client index.
 */
stock L4D_GetTankFrustration(client)
{
	return GetEntProp(client, Prop_Send, "m_frustration");
}

/**
 * Set tank player's frustration.
 *
 * @param client		Player index.
 * @param frustration	How frustrated tank player is.
 * @noreturn
 * @error				Invalid client index.
 */
stock L4D_SetTankFrustration(client, frustration)
{
	SetEntProp(client, Prop_Send, "m_frustration", frustration);
}

/**
 * Returns whether survivor player is idle.
 *
 * @param				Player index.
 * @return				True if idle, false otherwise.
 */
stock bool:L4D_IsPlayerIdle(client)
{
	return L4D_GetBotOfIdlePlayer(client) > -1;
}

/**
 * Returns survivor bot of idle survivor player.
 *
 * @param client		Player index.
 * @return				Player index of the bot, -1 if not found.
 */
stock L4D_GetBotOfIdlePlayer(client)
{
	new idleClient;
	for (new i = 0; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || 
			!IsFakeClient(i) ||
			L4DTeam:GetClientTeam(i) != L4DTeam_Survivor ||
			!IsPlayerAlive(i) ||
			GetClientHealth(i) < 1)
		{
			continue;
		}
		idleClient = GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID"));
		if (idleClient == client) return i;
	}

	return -1;
}

/**
 * Returns idle survivor player of survivor bot.
 *
 * @param bot			Player index of bot.
 * @return				Player index of idle client, -1 if not found.
 * @error				Invalid client index.
 */
stock L4D_GetIdlePlayerOfBot(bot)
{
	return GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID"));
}

/**
 * Returns resource entity.
 *
 * @return				Entity index of resource entity, -1 if not found.
 */
stock L4D_GetResourceEntity()
{
	return FindEntityByClassname(-1, "terror_player_manager");
}

/**
 * Retrieves client data from the resource entity.
 *
 * @param client		Player's index.
 * @param type			ResourceType constant
 * @return				Value or -1 on failure.
 * @error				Invalid client index, client not in game or failed to find resource entity.
 */
stock L4D_GetPlayerL4D2ResourceData(client, L4D2ResourceType:type)
{
	if (!IsClientConnected(client))
	{
		return -1;	
	}

	new offset = FindSendPropInfo("CTerrorPlayerResource", L4D2ResourceNames[type]);

	if (offset < 1)
	{
		return -1;	
	}

	new entity = L4D_GetResourceEntity();

	if (entity == -1)
	{
		return -1;
	}

	return GetEntData(entity, offset + (client * 4));
}

/**
 * Sets client data in the resource entity.
 *
 * Note: The game overwrites these values every frame, so changing them will have very little effect.
 *
 * @param client		Player's index.
 * @param type			ResourceType constant
 * @param value			Value to set.
 * @return				Value or -1 on failure.
 * @error				Invalid client index, client not in game or failed to find resource entity.
 */
stock bool:L4D_SetPlayerL4D2ResourceData(client, L4D2ResourceType:type, any:value)
{
	if (!IsClientConnected(client))
	{
		return false;	
	}

	new offset = FindSendPropInfo("CTerrorPlayerResource", L4D2ResourceNames[type]);

	if (offset < 1)
	{
		return false;	
	}

	new entity = L4D_GetResourceEntity();

	if (entity == -1)
	{
		return false;	
	}

	SetEntData(entity, offset + (client * 4), value);

	return true;	
}

/**
 * Removes the weapon from a client's weapon slot
 *
 * @param client		Player's index.
 * @param slot			Slot index.
 * @noreturn
 * @error				Invalid client or lack of mod support.
 */
stock L4D_RemoveWeaponSlot(client, L4DWeaponSlot:slot)
{
	new weaponIndex;
	while ((weaponIndex = GetPlayerWeaponSlot(client, _:slot)) != -1)
	{
		RemovePlayerItem(client, weaponIndex);
		RemoveEdict(weaponIndex);
	}
}

/**
 * Removes all weapons from a client
 *
 * @param client		Player's index.
 * @noreturn
 * @error				Invalid client or lack of mod support.
 */
stock L4D_RemoveAllWeapons(client)
{
	for (new i = 0; i <= 4; i++)
	{
		L4D_RemoveWeaponSlot(client, L4DWeaponSlot:i);
	}
}

/**
 * Returns whether the finale is active.
 *
 * @return				True if finale is active, false otherwise.
 */
stock bool:L4D_IsFinaleActive()
{
	new entity = L4D_GetResourceEntity();

	if (entity == -1)
	{
		return false;
	}

	return bool:GetEntProp(entity, Prop_Send, "m_isFinale", 1);
}

/**
 * Returns whether any survivor have left the safe area.
 *
 * @return				True if any survivor have left safe area, false 
 *						otherwise.
 */
stock bool:L4D_HasAnySurvivorLeftSafeArea()
{
	new entity = L4D_GetResourceEntity();

	if (entity == -1)
	{
		return false;
	}

	return bool:GetEntProp(entity, Prop_Send, "m_hasAnySurvivorLeftSafeArea", 1);
}

/**
 * Returns pending tank player.
 *
 * @return				Player index of pending tank player, -1 if not found.
 */
stock L4D_GetPendingTankPlayer()
{
	new entity = L4D_GetResourceEntity();

	if (entity == -1)
	{
		return -1;
	}

	return GetEntProp(entity, Prop_Send, "m_pendingTankPlayerIndex");
}

/**
 * Set entity glow. This is consider safer and more robust over setting each glow
 * property on their own because glow offset will be check first.
 *
 * Note: This function only works in L4D2
 *
 * @param entity		Entity index.
 * @parma type			Glow type.
 * @param range			Glow max range, 0 for unlimited.
 * @param minRange		Glow min range.
 * @param colorOverride Glow color, RGB.
 * @param flashing		Whether the glow will be flashing.
 * @return				True if glow was set, false if entity does not support
 *						glow.
 */
stock bool:L4D_SetEntityGlow(entity, L4DGlowType:type, range, minRange, colorOverride[3], bool:flashing)
{
	decl String:cls[128];
	GetEntityNetClass(entity, cls, 128);
	if (FindSendPropInfo(cls, "m_iGlowType") <= 0)
	{
		return false;
	}

	L4D_SetEntityGlow_Type(entity, type);
	L4D_SetEntityGlow_Range(entity, range);
	L4D_SetEntityGlow_MinRange(entity, minRange);
	L4D_SetEntityGlow_ColorOverride(entity, colorOverride);
	L4D_SetEntityGlow_Flashing(entity, flashing);
	return true;
}

/**
 * Set entity glow type.
 *
 * Note: This function only works in L4D2
 *
 * @param entity		Entity index.
 * @parma type			Glow type.
 * @noreturn
 * @error				Invalid entity index or entity does not support glow.
 */
stock L4D_SetEntityGlow_Type(entity, L4DGlowType:type)
{
	SetEntProp(entity, Prop_Send, "m_iGlowType", _:type);
}

/**
 * Set entity glow range.
 *
 * Note: This function only works in L4D2
 *
 * @param entity		Entity index.
 * @parma range			Glow range.
 * @noreturn
 * @error				Invalid entity index or entity does not support glow.
 */
stock L4D_SetEntityGlow_Range(entity, range)
{
	SetEntProp(entity, Prop_Send, "m_nGlowRange", range);
}

/**
 * Set entity glow min range.
 *
 * Note: This function only works in L4D2
 *
 * @param entity		Entity index.
 * @parma minRange		Glow min range.
 * @noreturn
 * @error				Invalid entity index or entity does not support glow.
 */
stock L4D_SetEntityGlow_MinRange(entity, minRange)
{
	SetEntProp(entity, Prop_Send, "m_nGlowRangeMin", minRange);
}

/**
 * Set entity glow color.
 *
 * Note: This function only works in L4D2
 *
 * @param entity		Entity index.
 * @parma colorOverride	Glow color, RGB.
 * @noreturn
 * @error				Invalid entity index or entity does not support glow.
 */
stock L4D_SetEntityGlow_ColorOverride(entity, colorOverride[3])
{
	SetEntProp(entity, Prop_Send, "m_glowColorOverride", colorOverride[0] + (colorOverride[1] * 256) + (colorOverride[2] * 65536));
}

/**
 * Set entity glow flashing state.
 *
 * Note: This function only works in L4D2
 *
 * @param entity		Entity index.
 * @parma flashing		Whether glow will be flashing.
 * @noreturn
 * @error				Invalid entity index or entity does not support glow.
 */
stock L4D_SetEntityGlow_Flashing(entity, bool:flashing)
{
	SetEntProp(entity, Prop_Send, "m_bFlashing", flashing);
}