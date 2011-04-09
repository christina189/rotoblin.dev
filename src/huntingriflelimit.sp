/**
 * =============================================================================
 * Rotoblin (C)2010-2011 Rotoblin Team
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

/*
 * ==================================================
 *                     Variables
 * ==================================================
 */

/*
 * --------------------
 *       Private
 * --------------------
 */

static	const	String:	WEAPON_HUNTING_RIFLE[]			= "weapon_hunting_rifle";

static			Handle:	g_hHuntingRifleLimit_Cvar 		= INVALID_HANDLE;
static					g_iHuntingRifleLimit			= 1;

static	const	Float:	TIP_COOLDOWN					= 8.0;
static			bool:	g_bHaveTipped[MAXPLAYERS + 1] 	= {false};

static					g_iDebugChannel;

/*
 * ==================================================
 *                     Forwards
 * ==================================================
 */

/**
 * Called on plugin start.
 *
 * @noreturn
 */
public _HRLimit_OnPluginStart()
{
	g_iDebugChannel = Debug_AddChannel("HuntingRifleLimit");

	g_hHuntingRifleLimit_Cvar = CreateConVarEx("huntingrifle_limit", "1", "Maximum of hunting rifles the survivors can pick up. 0 to disallow hunting rifles all together", FCVAR_NOTIFY | FCVAR_PLUGIN);

	HookGlobalForward(GFwd_OnPluginEnabled, _HRL_OnPluginEnabled);
	HookGlobalForward(GFwd_OnPluginDisabled, _HRL_OnPluginDisabled);
}

/**
 * Called on plugin enabled.
 *
 * @noreturn
 */
public _HRL_OnPluginEnabled()
{
	g_iHuntingRifleLimit = GetConVarInt(g_hHuntingRifleLimit_Cvar);
	if (g_iHuntingRifleLimit < 0) g_iHuntingRifleLimit = 0;
	HookConVarChange(g_hHuntingRifleLimit_Cvar, _HRL_Limit_CvarChange);

	HookGlobalForward(GFwd_OnClientPutInServer, _HRL_OnClientPutInServer);
	HookGlobalForward(GFwd_OnClientDisconnect, _HRL_OnClientDisconnect);

	FOR_EACH_CLIENT_IN_GAME(client)
	{
		SDKHook(client, SDKHook_WeaponCanUse, _HRL_OnWeaponCanUse);
		Debug_PrintTextEx("Hooked client %i", client);
	}

	Debug_PrintTextEx("Module enabled");
}

/**
 * Called on plugin disabled.
 *
 * @noreturn
 */
public _HRL_OnPluginDisabled()
{
	UnhookConVarChange(g_hHuntingRifleLimit_Cvar, _HRL_Limit_CvarChange);
	
	UnhookGlobalForward(GFwd_OnClientPutInServer, _HRL_OnClientPutInServer);
	UnhookGlobalForward(GFwd_OnClientDisconnect, _HRL_OnClientDisconnect);

	FOR_EACH_CLIENT_IN_GAME(client)
	{
		SDKUnhook(client, SDKHook_WeaponCanUse, _HRL_OnWeaponCanUse);
		Debug_PrintTextEx("Unhooked client %i", client);
	}

	Debug_PrintTextEx("Module disabled");
}

/**
 * Called on limit hunting rifle cvar changed.
 *
 * @param convar		Handle to the convar that was changed.
 * @param oldValue		String containing the value of the convar before it was changed.
 * @param newValue		String containing the new value of the convar.
 * @noreturn
 */
public _HRL_Limit_CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_iHuntingRifleLimit = StringToInt(newValue);
	if (g_iHuntingRifleLimit < 0) g_iHuntingRifleLimit = 0;
	Debug_PrintTextEx("New hunting rifle limit %i", g_iHuntingRifleLimit);
}

/**
 * Called on client put in server.
 *
 * @param client		Client index.
 * @noreturn
 */
public _HRL_OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, _HRL_OnWeaponCanUse);
	Debug_PrintTextEx("Hooked client %i", client);
}

/**
 * Called on client disconnect.
 *
 * @param client		Client index.
 * @noreturn
 */
public _HRL_OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_WeaponCanUse, _HRL_OnWeaponCanUse);
	Debug_PrintTextEx("Unhooked client %i", client);
}

/**
 * Called on weapon can use.
 *
 * @param client		Client index.
 * @param weapon		Weapon entity index.
 * @return				Plugin_Continue to allow weapon usage, Plugin_Handled
 *						to disallow weapon usage.
 */
public Action:_HRL_OnWeaponCanUse(client, weapon)
{
	if (L4DTeam:GetClientTeam(client) != L4DTeam_Survivor) return Plugin_Continue;

	decl String:classname[128];
	GetEdictClassname(weapon, classname, sizeof(classname));
	if (!StrEqual(classname, WEAPON_HUNTING_RIFLE)) return Plugin_Continue;

	Debug_PrintTextEx("Survivor client %i is trying to pick up hunting rifle", client);

	if (g_iHuntingRifleLimit <= 0)
	{
		if (!IsFakeClient(client) && !g_bHaveTipped[client])
		{
			PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Hunting rifle limit - Not allowed");
			g_bHaveTipped[client] = true;
			CreateTimer(TIP_COOLDOWN, _HRL_Tip_Timer, client);
		}
		Debug_PrintTextEx("No hunting rifle allowed");
		return Plugin_Handled; // No hunthing rifles allowed
	}

	new curWeapon = GetPlayerWeaponSlot(client, _:L4DWeaponSlot_Primary); // Get current primary weapon
	if (curWeapon != -1 && IsValidEntity(curWeapon))
	{
		GetEdictClassname(curWeapon, classname, sizeof(classname));
		if (StrEqual(classname, WEAPON_HUNTING_RIFLE))
		{
			Debug_PrintTextEx("Survivor already got a hunting rifle, allow refill");
			return Plugin_Continue; // Survivor already got a hunting rifle and trying to pick up a ammo refill, allow it
		}
	}

	if (GetActiveHuntingRifles() >= g_iHuntingRifleLimit) // If ammount of active hunting rifles are at the limit
	{
		if (!IsFakeClient(client) && !g_bHaveTipped[client])
		{
			PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Hunting rifle limit - At maximum");
			g_bHaveTipped[client] = true;
			CreateTimer(TIP_COOLDOWN, _HRL_Tip_Timer, client);
		}
		Debug_PrintTextEx("Hunting rifle at the limit, stop pick up");
		return Plugin_Handled; // Dont allow survivor picking up the hunting rifle
	}

	return Plugin_Continue;
}

/**
 * Called when tip interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @param client		Client index.
 * @return				Plugin_Stop.
 */
public Action:_HRL_Tip_Timer(Handle:timer, any:client)
{
	g_bHaveTipped[client] = false;
	return Plugin_Stop;
}

/*
 * ==================================================
 *                    Private API
 * ==================================================
 */

/**
 * Returns amount of active hunthing rifles equiped by the survivors.
 *
 * @return				Amount of active hunting rifles.
 */
static GetActiveHuntingRifles()
{
	new weapon;
	decl String:classname[128];
	new count = 0;
	FOR_EACH_ALIVE_SURVIVOR(client)
	{
		weapon = GetPlayerWeaponSlot(client, _:L4DWeaponSlot_Primary); // Get primary weapon
		if (weapon == -1 || !IsValidEntity(weapon)) continue;

		GetEdictClassname(weapon, classname, sizeof(classname));
		if (StrEqual(classname, WEAPON_HUNTING_RIFLE)) count++;
	}
	Debug_PrintTextEx("Active hunting rifles %i", count);
	return count;
}

/**
 * Wrapper for Debug_PrintText without having to define debug channel.
 *
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @noreturn
 */
static Debug_PrintTextEx(const String:format[], any:...)
{
	decl String:buffer[256];
	VFormat(buffer, sizeof(buffer), format, 2);
	Debug_PrintText(g_iDebugChannel, buffer);
}