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

static	const	String:	PUBLIC_CHAT_TRIGGER[]		= "!";
static	const	String:	SILENT_CHAT_TRIGGER[]		= "/";

static			Handle:	g_hCommandTrie				= INVALID_HANDLE;

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
public _PluginCommands_OnPluginStart()
{
	g_hCommandTrie = CreateTrie();
	AddCommandListener(_PC_Say_Command, "say");
	AddCommandListener(_PC_Say_Command, "say_team");
}

/**
 * Say command listener.
 *
 * @param client        Client, or 0 for server. Client will be connected but
 *                      not necessarily in game.
 * @param command       Command name, lower case. To get name as typed, use
 *                      GetCmdArg() and specify argument 0.
 * @param argc          Argument count.
 * @return				Returning Plugin_Handled or Plugin_Stop will prevent
 *						the original, baseline code from running.
 */ 
public Action:_PC_Say_Command(client, const String:command[], argc)
{
	if (argc != 1) return Plugin_Continue;

	decl String:buffer[128];
	GetCmdArg(1, buffer, sizeof(buffer));

	new pos;
	new bool:hideSay;
	if ((pos = StrContains(buffer, SILENT_CHAT_TRIGGER)) == 0) 
	{
		hideSay = true;
	}
	else if ((pos = StrContains(buffer, PUBLIC_CHAT_TRIGGER)) == 0) 
	{
		hideSay = false;
	}
	else
	{
		return Plugin_Continue;
	}

	strcopy(buffer, sizeof(buffer), buffer[pos + 1]); // Strip trigger from left side

	decl String:pluginCommand[128];
	if (GetTrieString(g_hCommandTrie, buffer, pluginCommand, 128))
	{
		FakeClientCommandEx(client, pluginCommand);
		if (hideSay) return Plugin_Handled;
	}

	return Plugin_Continue;
}

/*
 * ==================================================
 *                     Public API
 * ==================================================
 */

/**
 * Adds a command listener to the provided command and hooks say command as
 * well. The command will be prefixed by the plugins cmd prefix.
 * 
 * @param callback		Callback.
 * @param command		Command. The command is case insensitive.
 * @return				True upon hooked, false otherwise
 */
stock bool:AddCommandListenerEx(CommandListener:callback, const String:command[])
{
	decl String:buffer[128];
	Format(buffer, sizeof(buffer), "%s_%s", PLUGIN_CMD_PREFIX, command);

	if (!AddCommandListener(callback, buffer)) return false; // If unable to hook, return false

	SetTrieString(g_hCommandTrie, command, buffer);

	return true;
}

/**
 * Removes a command listener to the provided command and remove hooks for say 
 * command as well. The command will be prefixed by the plugins cmd prefix.
 * 
 * @param callback		Callback.
 * @param command		Command. The command is case insensitive.
 * @noreturn
 */
stock RemoveCommandListenerEx(CommandListener:callback, const String:command[])
{
	decl String:buffer[128];
	Format(buffer, sizeof(buffer), "%s_%s", PLUGIN_CMD_PREFIX, command);
	RemoveCommandListener(callback, buffer);

	RemoveFromTrie(g_hCommandTrie, command);
}