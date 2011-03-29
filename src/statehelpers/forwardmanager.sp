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
 *                    Preprocessor
 * ==================================================
 */

#define MAX_GLOBAL_FORWARDS 10

/*
 * ==================================================
 *                     Variables
 * ==================================================
 */

/*
 * --------------------
 *       Public
 * --------------------
 */

enum GlobalForwardType
{
	Handle:GFwd_OnLibraryAdded,
	Handle:GFwd_OnLibraryRemoved,
	Handle:GFwd_OnAllPluginsLoaded,
	Handle:GFwd_OnPluginEnabled,
	Handle:GFwd_OnPluginDisabled,
	Handle:GFwd_OnMapStart,
	Handle:GFwd_OnMapEnd,
	Handle:GFwd_OnClientPutInServer,
	Handle:GFwd_OnClientDisconnect,
	Handle:GFwd_OnPlayerRunCmd
}

/*
 * --------------------
 *       Private
 * --------------------
 */

static					g_hForwards[MAX_GLOBAL_FORWARDS];

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
public _ForwardManager_OnPluginStart()
{
	g_hForwards[GFwd_OnLibraryAdded] 				= CreateForward(ET_Ignore, Param_String);
	g_hForwards[GFwd_OnLibraryRemoved] 				= CreateForward(ET_Ignore, Param_String);
	g_hForwards[GFwd_OnAllPluginsLoaded]			= CreateForward(ET_Ignore);
	g_hForwards[GFwd_OnPluginEnabled] 				= CreateForward(ET_Ignore);
	g_hForwards[GFwd_OnPluginDisabled] 				= CreateForward(ET_Ignore);
	g_hForwards[GFwd_OnMapStart] 					= CreateForward(ET_Ignore);
	g_hForwards[GFwd_OnMapEnd] 						= CreateForward(ET_Ignore);
	g_hForwards[GFwd_OnClientPutInServer] 			= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[GFwd_OnClientDisconnect] 			= CreateForward(ET_Ignore, Param_Cell);
	g_hForwards[GFwd_OnPlayerRunCmd] 				= CreateForward(ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
}

/**
 * Called after a library is added that the current plugin references 
 * optionally. A library is either a plugin name or extension name, as exposed
 * via its include file.
 *
 * @param name			Library name.
 * @noreturn
 */
public OnLibraryAdded(const String:name[])
{
	Call_StartForward(g_hForwards[GFwd_OnLibraryAdded]);
	Call_PushString(name);
	Call_Finish();
}

/**
 * Called right before a library is removed that the current plugin references
 * optionally. A library is either a plugin name or extension name, as exposed
 * via its include file.
 *
 * @param name			Library name.
 * @noreturn
 */
public OnLibraryRemoved(const String:name[])
{
	Call_StartForward(g_hForwards[GFwd_OnLibraryRemoved]);
	Call_PushString(name);
	Call_Finish();
}

/**
 * Called on all plugins loaded.
 *
 * @noreturn
 */
public OnAllPluginsLoaded()
{
	Call_StartForward(g_hForwards[GFwd_OnAllPluginsLoaded]);
	Call_Finish();
}

/**
 * Called on plugin enabled.
 *
 * @noreturn
 */
public Rotoblin_OnEnabled()
{
	Call_StartForward(g_hForwards[GFwd_OnPluginEnabled]);
	Call_Finish();
}

/**
 * Called on plugin disabled.
 *
 * @noreturn
 */
public Rotoblin_OnDisabled()
{
	Call_StartForward(g_hForwards[GFwd_OnPluginDisabled]);
	Call_Finish();
}

/**
 * Called on map start.
 *
 * @noreturn
 */
public OnMapStart()
{
	Call_StartForward(g_hForwards[GFwd_OnMapStart]);
	Call_Finish();
}

/**
 * Called on map end.
 *
 * @noreturn
 */
public OnMapEnd()
{
	Call_StartForward(g_hForwards[GFwd_OnMapEnd]);
	Call_Finish();
}

/**
 * Called on client put in server.
 *
 * @param client		Client index.
 * @noreturn
 */
public OnClientPutInServer(client)
{
	if (client == 0) return; // Don't forward server index

	Call_StartForward(g_hForwards[GFwd_OnClientPutInServer]);
	Call_PushCell(client);
	Call_Finish();
}

/**
 * Called on client disconnect.
 *
 * @param client		Client index.
 * @noreturn
 */
public OnClientDisconnect(client)
{
	if (client == 0) return; // Don't forward server index

	Call_StartForward(g_hForwards[GFwd_OnClientDisconnect]);
	Call_PushCell(client);
	Call_Finish();
}

/**
 * Called when a clients movement buttons are being processed.
 *
 * @param client		Index of the client.
 * @param buttons		Copyback buffer containing the current commands (as bitflags - see entity_prop_stocks.inc).
 * @param impulse		Copyback buffer containing the current impulse command.
 * @param vel			Players desired velocity.
 * @param angles		Players desired view angles.
 * @param weapon		Entity index of the new weapon if player switches weapon, 0 otherwise.
 * @return				Plugin_Handled to block the commands from being processed, Plugin_Continue otherwise.
 */
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (client == 0) return Plugin_Continue; // Don't forward server index

	new Action:result = Plugin_Continue;
	Call_StartForward(g_hForwards[GFwd_OnPlayerRunCmd]);
	Call_PushCell(client);
	Call_PushCellRef(buttons);
	Call_PushCellRef(impulse);
	Call_PushArray(vel, 3);
	Call_PushArray(angles, 3);
	Call_PushCellRef(weapon);
	Call_Finish(_:result);
	return result;
}

/*
 * ==================================================
 *                     Public API
 * ==================================================
 */

/**
 * Hooks the function to the forward of selected type.
 * 
 * @param type			The type of forward.
 * @param func			The function to add.
 * @return				True on success, false otherwise.
 */
stock bool:HookGlobalForward(GlobalForwardType:type, Function:func)
{
	return AddToForward(Handle:g_hForwards[type], INVALID_HANDLE, func);
}

/**
 * Unhooks the function from the forward of selected type.
 * 
 * @param type			The type of forward.
 * @param func			The function to add.
 * @return				True on success, false otherwise.
 */
stock bool:UnhookGlobalForward(GlobalForwardType:type, Function:func)
{
	return RemoveFromForward(Handle:g_hForwards[type], INVALID_HANDLE, func);
}