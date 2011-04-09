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

static	const			OUTPUT_TO_SERVER				= (1 << 0);
static	const			OUTPUT_TO_CHAT					= (1 << 1);
static	const			OUTPUT_TO_LOG					= (1 << 2);

static	const			CHANNEL_ALL_FLAG				= (1 << 0);
static	const	String:	CHANNEL_ALL_NAME[]				= "All modules";
static	const	String:	CHANNEL_KEY_NAME[]				= "_name";
static	const	String:	CHANNEL_KEY_FLAG[]				= "_flag";

static			Handle:	g_hChannelsTrie					= INVALID_HANDLE;
static					g_iNextChannel_Flag				= (1 << 0);
static					g_iNextChannel_Index			= 0;

static					g_iOutputFlags					= 0;
static					g_iChannelFlags					= 0;

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
public _PluginDebug_OnPluginStart()
{
	g_hChannelsTrie = CreateTrie();

	// Setup the all modules channel
	Debug_AddChannel(CHANNEL_ALL_NAME);

	decl Handle:cvar;
	cvar = CreateConVarEx("debug_channel", "0", "Sum of debug channel flags.", FCVAR_PLUGIN);
	g_iChannelFlags = GetConVarInt(cvar);
	HookConVarChange(cvar, _PD_Channel_CvarChange);

	cvar = CreateConVarEx("debug_output", "0", "Sum of debug output flags. 0 - No logging, 1 - Print to server, 2 - Print to chat, 4 - Log to SM logs", FCVAR_PLUGIN);
	g_iOutputFlags = GetConVarInt(cvar);
	HookConVarChange(cvar, _PD_Output_CvarChange);

	RegAdminCmdEx("debug_status", _PD_Status_Command, ADMFLAG_ROOT, "Writes report of channels and what is current listen to", PLUGIN_CMD_GROUP, FCVAR_PLUGIN);
}

/**
 * Channel cvar changed.
 *
 * @param convar		Handle to the convar that was changed.
 * @param oldValue		String containing the value of the convar before it was changed.
 * @param newValue		String containing the new value of the convar.
 * @noreturn
 */
public _PD_Channel_CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_iChannelFlags = StringToInt(newValue);
}

/**
 * Output cvar changed.
 *
 * @param convar		Handle to the convar that was changed.
 * @param oldValue		String containing the value of the convar before it was changed.
 * @param newValue		String containing the new value of the convar.
 * @noreturn
 */
public _PD_Output_CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_iOutputFlags = StringToInt(newValue);
}

/**
 * Called when debug status command is invoked.
 *
 * @param client		Index of the client, or 0 from the server.
 * @param args			Number of arguments that were in the argument string.
 * @return				An Action value.  Not handling the command
 *						means that Source will report it as "not found."
 */
public Action:_PD_Status_Command(client, args)
{
	decl channelFlag, String:channelName[128], String:buffer[128], String:result[1024];
	new channelCounter = 0;

	Format(result, sizeof(result), "\n==================================================\n");
	Format(result, sizeof(result), "%s%s Debug Management\n\n  Debug status:\n    Current channel flag: %i\n    Current output flag: %i\n\n", result, PLUGIN_FULLNAME, g_iChannelFlags, g_iOutputFlags);
	Format(result, sizeof(result), "%s  Channel Listing:\n    #flag : module name\n    -----\n", result);

	for (new i = 0; i < g_iNextChannel_Index; i++)
	{
		Format(buffer, sizeof(buffer), "%s%s", i, CHANNEL_KEY_FLAG);
		if (!GetTrieValue(g_hChannelsTrie, buffer, channelFlag)) continue;

		Format(buffer, sizeof(buffer), "%s%s", i, CHANNEL_KEY_NAME);
		if (!GetTrieString(g_hChannelsTrie, buffer, channelName, sizeof(channelName))) continue;

		Format(result, sizeof(result), "%s    #%-5i: %s\n", result, channelFlag, channelName);
		channelCounter++;
	}

	Format(result, sizeof(result), "%s    -----\n    Total channels: %i\n\n", result, channelCounter);
	Format(result, sizeof(result), "%s==================================================\n", result);

	if (client == 0)
	{
		PrintToServer(result);
	}
	else
	{
		ReplyToCommand(client, "[%s] Debug status printed to console", PLUGIN_TAG);
		PrintToConsole(client, result);
	}

	return Plugin_Handled;
}

/*
 * ==================================================
 *                     Public API
 * ==================================================
 */

/**
 * Adds a debug channel.
 *
 * @param channelName	Name of the channel.
 * @return				Channel index.
 */
stock Debug_AddChannel(const String:channelName[])
{
	new channelIndex = g_iNextChannel_Index;
	new channelFlag = g_iNextChannel_Flag;

	decl String:buffer[128];

	// Store flag
	Format(buffer, sizeof(buffer), "%s%s", channelIndex, CHANNEL_KEY_FLAG);
	SetTrieValue(g_hChannelsTrie, buffer, channelFlag);

	// Store channel name
	Format(buffer, sizeof(buffer), "%s%s", channelIndex, CHANNEL_KEY_NAME);
	SetTrieString(g_hChannelsTrie, buffer, channelName);

	g_iNextChannel_Index++;
	g_iNextChannel_Flag *= 2;
	return channelIndex;
}

/**
 * Prints a debug message.
 *
 * @param channelIndex	Index of channel.
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @noreturn
 */
stock Debug_PrintText(channelIndex, const String:format[], any:...)
{
	if (g_iOutputFlags == 0) return;

	decl String:buffer[256];

	decl channelFlag;
	Format(buffer, sizeof(buffer), "%s%s", channelIndex, CHANNEL_KEY_FLAG);
	if (!GetTrieValue(g_hChannelsTrie, buffer, channelFlag)) return; // Unable to get channel flag, return

	if (!(g_iChannelFlags & channelFlag) && g_iChannelFlags != CHANNEL_ALL_FLAG) return; // Channel flags does not contain this channel and we arent logging all channels, return

	decl String:channelName[128];
	Format(buffer, sizeof(buffer), "%s%s", channelIndex, CHANNEL_KEY_NAME);
	GetTrieString(g_hChannelsTrie, buffer, channelName, sizeof(channelName));

	VFormat(buffer, sizeof(buffer), format, 3);

	if (g_iOutputFlags & OUTPUT_TO_SERVER)
	{
		PrintToServer("[%s][%s] %s", PLUGIN_TAG, channelName, buffer);
	}
	if (g_iOutputFlags & OUTPUT_TO_CHAT)
	{
		PrintToChatAll("[%s][%s] %s", PLUGIN_TAG, channelName, buffer);
	}
	if (g_iOutputFlags & OUTPUT_TO_LOG)
	{
		LogMessage("[%s] %s", channelName, buffer);
	}
}