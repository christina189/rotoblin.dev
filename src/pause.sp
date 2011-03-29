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

static	const	String:	PAUSABLE_CVAR[]				= "sv_pausable";
static	const	String:	ALL_BOT_TEAM_CVAR[]			= "sb_all_bot_team";

static	const	String:	PLUGIN_PAUSE_COMMAND[]		= "fpause";
static	const	String:	PLUGIN_UNPAUSE_COMMAND[]	= "funpause";
static	const	String:	PLUGIN_FORCEPAUSE_COMMAND[]	= "forcepause";
static	const	String:	PAUSE_COMMAND[]				= "pause";
static	const	String:	SETPAUSE_COMMAND[]			= "setpause";
static	const	String:	UNPAUSE_COMMAND[]			= "unpause";

static	const	Float:	RESET_PAUSE_REQUESTS_TIME	= 30.0;

static	const	String:	SILENT_CHAT_TRIGGER[]		= "/";

static	const	Float:	RESET_ALL_BOT_TEAM_TIME		= 10.0;
static			Handle:	g_hAllBotTeam_Cvar			= INVALID_HANDLE;
static			bool:	g_bResetAllBotTeam			= false;

static			Handle:	g_hPauseEnable_Cvar			= INVALID_HANDLE;
static			bool:	g_bIsPauseEnable			= true;

static			Handle: g_hPausable					= INVALID_HANDLE;
static			bool:	g_bIsPausable				= false;
static			bool:	g_bIsUnpausable				= false;
static			bool:	g_bIsPaused					= false;
static			bool:	g_bIsUnpausing				= false;
static			bool:	g_bWasForced				= false;

static			bool:	g_bSurvivorRequest			= false;
static			bool:	g_bInfectedRequest			= false;

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
public _Pause_OnPluginStart()
{
	g_hPauseEnable_Cvar = CreateConVarEx("pause", "1", "Sets whether the game can be paused", FCVAR_NOTIFY | FCVAR_PLUGIN);

	HookGlobalForward(GFwd_OnPluginEnabled, _P_OnPluginEnabled);
	HookGlobalForward(GFwd_OnPluginDisabled, _P_OnPluginDisabled);
}

/**
 * Called on plugin end.
 *
 * @noreturn
 */
public _Pause_OnPluginEnd()
{
	if (g_bIsPaused)
	{
		Unpause();
	}
	g_bIsPausable = false;
	g_bIsUnpausable = false;
	g_bIsPaused = false;
	g_bIsUnpausing = false;
}

/**
 * Called on plugin enabled.
 *
 * @noreturn
 */
public _P_OnPluginEnabled()
{
	g_bIsPausable = false;
	g_bIsUnpausable = false;
	g_bIsPaused = false;
	g_bIsUnpausing = false;
	g_bWasForced = false;
	ResetPauseRequests();

	g_hPausable = FindConVar(PAUSABLE_CVAR);
	SetConVarInt(g_hPausable, 0); // Disable pausing

	g_hAllBotTeam_Cvar = FindConVar(ALL_BOT_TEAM_CVAR);

	g_bIsPauseEnable = GetConVarBool(g_hPauseEnable_Cvar);
	HookConVarChange(g_hPauseEnable_Cvar, _P_PauseEnable_CvarChange);

	HookGlobalForward(GFwd_OnMapEnd, _P_OnMapEnd);

	AddCommandListenerEx(_P_PluginPause_Command, PLUGIN_PAUSE_COMMAND);
	AddCommandListenerEx(_P_PluginUnpause_Command, PLUGIN_UNPAUSE_COMMAND);
	AddCommandListenerEx(_P_PluginForcePause_Command, PLUGIN_FORCEPAUSE_COMMAND);
	AddCommandListener(_P_Pause_Command, PAUSE_COMMAND);
	AddCommandListener(_P_Setpause_Command, SETPAUSE_COMMAND);
	AddCommandListener(_P_Unpause_Command, UNPAUSE_COMMAND);
	AddCommandListener(_P_Say_Command, "say");
	AddCommandListener(_P_SayTeam_Command, "say_team");
}

/**
 * Called on plugin disabled.
 *
 * @noreturn
 */
public _P_OnPluginDisabled()
{
	RemoveCommandListenerEx(_P_PluginPause_Command, PLUGIN_PAUSE_COMMAND);
	RemoveCommandListenerEx(_P_PluginUnpause_Command, PLUGIN_UNPAUSE_COMMAND);
	RemoveCommandListenerEx(_P_PluginForcePause_Command, PLUGIN_FORCEPAUSE_COMMAND);
	RemoveCommandListener(_P_Pause_Command, PAUSE_COMMAND);
	RemoveCommandListener(_P_Setpause_Command, SETPAUSE_COMMAND);
	RemoveCommandListener(_P_Unpause_Command, UNPAUSE_COMMAND);
	RemoveCommandListener(_P_Say_Command, "say");
	RemoveCommandListener(_P_SayTeam_Command, "say_team");

	UnhookGlobalForward(GFwd_OnMapEnd, _P_OnMapEnd);

	UnhookConVarChange(g_hPauseEnable_Cvar, _P_PauseEnable_CvarChange);

	if (g_bIsPaused)
	{
		Unpause();
	}
	g_bIsPausable = false;
	g_bIsUnpausable = false;
	g_bIsPaused = false;
	g_bIsUnpausing = false;
	g_bWasForced = false;
	g_bResetAllBotTeam = false;
	ResetPauseRequests();
}

/**
 * Called on map end.
 *
 * @noreturn
 */
public _P_OnMapEnd()
{
	g_bIsPausable = false;
	g_bIsUnpausable = false;
	g_bIsPaused = false;
	g_bIsUnpausing = false;
	g_bWasForced = false;
	g_bResetAllBotTeam = false;
	ResetPauseRequests();
}

/**
 * Pause enable cvar changed.
 *
 * @param convar		Handle to the convar that was changed.
 * @param oldValue		String containing the value of the convar before it was changed.
 * @param newValue		String containing the new value of the convar.
 * @noreturn
 */
public _P_PauseEnable_CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_bIsPauseEnable = GetConVarBool(g_hPauseEnable_Cvar);
}

/**
 * On client use say command.
 *
 * @param client		Client id that performed the command.
 * @param command		The command performed.
 * @param args			Number of arguments.
 * @return				Plugin_Handled to stop command from being performed, 
 *						Plugin_Continue to allow the command to pass.
 */
public Action:_P_Say_Command(client, const String:command[], args)
{
	if (!g_bIsPaused) return Plugin_Continue;

	decl String:buffer[128];
	GetCmdArg(1, buffer, sizeof(buffer));
	if (StrContains(buffer, SILENT_CHAT_TRIGGER) == 0) return Plugin_Continue; // Silent chat trigger

	if (L4DTeam:GetClientTeam(client) == L4DTeam_Spectator)
	{
		FOR_EACH_CLIENT_IN_GAME(i)
		{
			PrintToChat(i, "\x01%t \x03%N\x01 : %s", "Pause - *SPEC*", client, buffer);
		}
	}
	else
	{
		PrintToChatAll("\x01\x03%N\x01 : %s", client, buffer);
	}

	return Plugin_Handled;
}

/**
 * On client use say team command
 *
 * @param client		Client id that performed the command.
 * @param command		The command performed.
 * @param args			Number of arguments.
 * @return				Plugin_Handled to stop command from being performed, 
 *						Plugin_Continue to allow the command to pass.
 */
public Action:_P_SayTeam_Command(client, const String:command[], args)
{
	if (!g_bIsPaused) return Plugin_Continue;

	decl String:buffer[128];
	GetCmdArg(1, buffer, sizeof(buffer));
	if (StrContains(buffer, SILENT_CHAT_TRIGGER) == 0) return Plugin_Continue; // Silent chat trigger

	new L4DTeam:team = L4DTeam:GetClientTeam(client);
	decl String:teamName[32];

	switch (team)
	{
		case L4DTeam_Spectator:
		{
			strcopy(teamName, 32, "Spectators");
		}

		case L4DTeam_Survivor:
		{
			strcopy(teamName, 32, "Survivors");
		}

		case L4DTeam_Infected:
		{
			strcopy(teamName, 32, "Infected");
		}
	}

	FOR_EACH_HUMAN_ON_TEAM(i, team)
	{
		PrintToChat(i, "\x01(%t) \x03%N\x01 : %s", teamName, client, buffer);
	}

	return Plugin_Handled;
}

/**
 * Called on pause command is invoked.
 *
 * @param client		Client id that performed the command.
 * @param command		The command performed.
 * @param args			Number of arguments.
 * @return				Plugin_Handled to stop command from being performed, 
 *						Plugin_Continue to allow the command to pass.
 */
public Action:_P_Pause_Command(client, const String:command[], args)
{
	return Plugin_Handled; // Block & ignore the pause command completely
}

/**
 * Called on set pause command is invoked.
 *
 * @param client		Client id that performed the command.
 * @param command		The command performed.
 * @param args			Number of arguments.
 * @return				Plugin_Handled to stop command from being performed, 
 *						Plugin_Continue to allow the command to pass.
 */
public Action:_P_Setpause_Command(client, const String:command[], args)
{
	if (!g_bIsPausable) return Plugin_Handled;

	g_bIsPaused = true;
	g_bIsUnpausing = false;
	g_bIsPausable = false;
	return Plugin_Continue;
}

/**
 * Called on unpause command is invoked.
 *
 * @param client		Client id that performed the command.
 * @param command		The command performed.
 * @param args			Number of arguments.
 * @return				Plugin_Handled to stop command from being performed, 
 *						Plugin_Continue to allow the command to pass.
 */
public Action:_P_Unpause_Command(client, const String:command[], args)
{
	if (!g_bIsUnpausable) return Plugin_Handled;

	g_bIsPaused = false;
	g_bIsUnpausing = false;
	g_bIsUnpausable = false;
	ResetPauseRequests();
	return Plugin_Continue;
}

/**
 * Called on plugin pause command is invoked.
 *
 * @param client		Client id that performed the command.
 * @param command		The command performed.
 * @param args			Number of arguments.
 * @return				Plugin_Handled to stop command from being performed, 
 *						Plugin_Continue to allow the command to pass.
 */
public Action:_P_PluginPause_Command(client, const String:command[], args)
{
	if (client == 0)
	{
		PrintToServer("%T", "Pause - Not from rcon", LANG_SERVER);
		return Plugin_Handled;
	}

	if (!g_bIsPauseEnable)
	{
		PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Pause - Disabled");
		return Plugin_Handled;
	}

	if (g_bIsPaused)
	{
		decl String:unpauseCommand[32];
		Format(unpauseCommand, 32, "!%s", PLUGIN_UNPAUSE_COMMAND);
		PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Pause - Already paused", unpauseCommand);
		return Plugin_Handled;
	}

	new L4DTeam:team = L4DTeam:GetClientTeam(client);
	if (team != L4DTeam_Survivor && team != L4DTeam_Infected)
	{
		PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Pause - Spectators can not pause");
		return Plugin_Handled;
	}

	switch (team)
	{
		case L4DTeam_Survivor:
		{
			if (g_bSurvivorRequest) return Plugin_Handled;
			g_bSurvivorRequest = true;
		}

		case L4DTeam_Infected:
		{
			if (g_bInfectedRequest) return Plugin_Handled;
			g_bInfectedRequest = true;
		}
	}

	if (g_bSurvivorRequest && g_bInfectedRequest)
	{
		decl String:unpauseCommand[32];
		Format(unpauseCommand, 32, "!%s", PLUGIN_UNPAUSE_COMMAND);
		FOR_EACH_HUMAN(i)
		{
			PrintToChat(i, "[%s] %t", PLUGIN_TAG, "Pause - Accepted", unpauseCommand);
		}
		Pause(client);
	}
	else
	{
		decl String:teamName[32];
		decl String:oppTeamName[32];

		switch (team)
		{
			case L4DTeam_Survivor:
			{
				strcopy(teamName, 32, "Survivors");
				strcopy(oppTeamName, 32, "Infected");
			}
			case L4DTeam_Infected:
			{
				strcopy(teamName, 32, "Infected");
				strcopy(oppTeamName, 32, "Survivors");
			}
		}

		decl String:tTeamName[32];
		decl String:tOppTeamName[32];
		decl String:pauseCommand[32];
		Format(pauseCommand, 32, "!%s", PLUGIN_PAUSE_COMMAND);
		FOR_EACH_HUMAN(i)
		{
			Format(tTeamName, 32, "%T", teamName, i);
			Format(tOppTeamName, 32, "%T", oppTeamName, i);
			PrintToChat(i, "[%s] %t", PLUGIN_TAG, "Pause - Request", tTeamName, tOppTeamName, pauseCommand);
		}

		CreateTimer(RESET_PAUSE_REQUESTS_TIME, _P_ResetPauseRequests_Timer);
	}

	return Plugin_Handled;
}

/**
 * Called on plugin unpause command is invoked.
 *
 * @param client		Client id that performed the command.
 * @param command		The command performed.
 * @param args			Number of arguments.
 * @return				Plugin_Handled to stop command from being performed, 
 *						Plugin_Continue to allow the command to pass.
 */
public Action:_P_PluginUnpause_Command(client, const String:command[], args)
{
	if (client == 0)
	{
		PrintToServer("%T", "Unpause - Not from rcon", LANG_SERVER);
		return Plugin_Handled;
	}

	if (!g_bIsPauseEnable)
	{
		PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Pause - Disabled");
		return Plugin_Handled;
	}

	if (!g_bIsPaused)
	{
		decl String:pauseCommand[32];
		Format(pauseCommand, 32, "!%s", PLUGIN_PAUSE_COMMAND);
		PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Unpause - Game is not paused", pauseCommand);
		return Plugin_Handled;
	}

	if (g_bIsUnpausing)
	{
		PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Unpuase - Already unpausing");
		return Plugin_Handled;
	}

	if (g_bWasForced) // An admin forced the game to pause so only an admin can unpause it
	{
		decl String:pauseCommand[32];
		Format(pauseCommand, 32, "!%s", PLUGIN_FORCEPAUSE_COMMAND);
		PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Unpause - Only admin can unpause", pauseCommand);
		return Plugin_Handled;
	}

	new L4DTeam:team = L4DTeam:GetClientTeam(client);

	if (team != L4DTeam_Survivor && team != L4DTeam_Infected)
	{
		PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Unpause - Spectators can not unpause");
		return Plugin_Handled;
	}

	decl String:teamName[32];
	switch (team)
	{
		case L4DTeam_Survivor:
		{
			strcopy(teamName, 32, "Survivors");
		}
		case L4DTeam_Infected:
		{
			strcopy(teamName, 32, "Infected");
		}
	}

	decl String:tTeamName[32];
	FOR_EACH_HUMAN(i)
	{
		Format(tTeamName, 32, "%T", teamName, i);
		PrintToChat(i, "[%s] %t", PLUGIN_TAG, "Unpause - Resuming", tTeamName);
	}

	g_bIsUnpausing = true;
	CreateTimer(1.0, _P_Unpause_Timer, client, TIMER_REPEAT); // Start unpause countdown
	return Plugin_Handled;
}

/**
 * Called on plugin force pause command is invoked.
 *
 * @param client		Client id that performed the command.
 * @param command		The command performed.
 * @param args			Number of arguments.
 * @return				Plugin_Handled to stop command from being performed, 
 *						Plugin_Continue to allow the command to pass.
 */
public Action:_P_PluginForcePause_Command(client, const String:command[], args)
{
	if (client == 0)
	{
		PrintToServer("[%s] %T", PLUGIN_TAG, "Force pause - Not from rcon", LANG_SERVER);
		return Plugin_Handled;
	}

	if (!g_bIsPauseEnable)
	{
		PrintToChat(client, "[%s] %t", PLUGIN_TAG, "Pause - Disabled");
		return Plugin_Handled;
	}

	if (!CheckCommandAccess(client, "", ADMFLAG_GENERIC, true))
	{
		PrintToChat(client, "[%s] %t", PLUGIN_TAG, "No Access");
		return Plugin_Handled;
	}

	if (g_bIsPaused && !g_bIsUnpausing) // Is paused and not currently unpausing
	{
		g_bWasForced = false;

		FOR_EACH_HUMAN(i)
		{
			PrintToChat(i, "[%s] %t", PLUGIN_TAG, "Unpause - Forced");
		}

		g_bIsUnpausing = true; // Set unpausing state
		CreateTimer(1.0, _P_Unpause_Timer, client, TIMER_REPEAT); // Start unpause countdown
	}
	else if (!g_bIsPaused) // Is not paused
	{
		g_bWasForced = true; // Pause was forced so only allow admins to unpause

		FOR_EACH_HUMAN(i)
		{
			PrintToChat(i, "[%s] %t", PLUGIN_TAG, "Pause - Forced");
		}

		Pause(client);
	}
	return Plugin_Handled;
}

/**
 * Called when the timer interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop to stop repeating, any other value for
 *						default behavior.
 */
public Action:_P_Unpause_Timer(Handle:timer, any:client)
{
	if (!g_bIsUnpausing) return Plugin_Stop; // Server was repaused/unpaused before the countdown finished

	static const maxCountdown = 3;
	static iCountdown = 3;

	if (iCountdown == maxCountdown)
	{
		FOR_EACH_HUMAN(i)
		{
			PrintToChat(i, "%t", "Unpause - Countdown - Will resume", iCountdown);
		}
		iCountdown--;
		return Plugin_Continue;
	}
	else if (iCountdown == 0)
	{
		FOR_EACH_HUMAN(i)
		{
			PrintToChat(i, "%t", "Unpause - Countdown - Done");
		}
		Unpause(client);
		iCountdown = maxCountdown;
		return Plugin_Stop;
	}

	FOR_EACH_HUMAN(i)
	{
		PrintToChat(i, "%t", "Unpause - Countdown", iCountdown);
	}
	iCountdown--;
	return Plugin_Continue;
}

/**
 * Called when the timer for reset of pause requests interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop.
 */
public Action:_P_ResetPauseRequests_Timer(Handle:timer)
{
	ResetPauseRequests();
	return Plugin_Stop;
}

/**
 * Called when reset all bot team interval has elapsed.
 * 
 * @param timer			Handle to the timer object.
 * @return				Plugin_Stop.
 */
public Action:_P_ResetAllBotTeam_Timer(Handle:timer)
{
	SetConVarBool(g_hAllBotTeam_Cvar, false);
	return Plugin_Stop;
}

/*
 * ==================================================
 *                     Public API
 * ==================================================
 */

/*
 * ==================================================
 *                    Private API
 * ==================================================
 */

/**
 * Resets pause requests for both teams.
 * 
 * @noreturn
 */
static ResetPauseRequests()
{
	g_bSurvivorRequest = false;
	g_bInfectedRequest = false;
}

/**
 * Pauses the game.
 *
 * @param client		Client that will be selected to pause the game, if not provided
 *						a random client will be used.
 * @noreturn
 */
static Pause(client = 0)
{
	if (client == 0 || !IsClientInGame(client) || IsFakeClient(client))
	{
		client = GetAnyClient(true);
		if (!client) return; // Couldn't find any clients to pause the game
	}

	g_bIsPausable = true; // Allow the next setpause command to go through

	SetConVarInt(g_hPausable, 1);
	FakeClientCommand(client, SETPAUSE_COMMAND);
	SetConVarInt(g_hPausable, 0);
	ResetPauseRequests();

	if (!GetConVarBool(g_hAllBotTeam_Cvar))
	{
		SetConVarBool(g_hAllBotTeam_Cvar, true); // Set sb_all_bot_team to true to prevent director glicthing when unpausing
		g_bResetAllBotTeam = true;
	}
}

/**
 * Unpauses the game.
 *
 * @param client		Client that will be selected to unpause the game, if not provided
 *						a random client will be used.
 * @noreturn
 */
static Unpause(client = 0)
{
	if (client == 0 || !IsClientInGame(client) || IsFakeClient(client))
	{
		client = GetAnyClient(true);
		if (!client) return; // Couldn't find any clients to unpause the game
	}

	g_bIsUnpausable = true; // Allow the next unpause command to go through

	SetConVarInt(g_hPausable, 1);
	FakeClientCommand(client, UNPAUSE_COMMAND);
	SetConVarInt(g_hPausable, 0);
	ResetPauseRequests();

	if (g_bResetAllBotTeam)
	{
		CreateTimer(RESET_ALL_BOT_TEAM_TIME, _P_ResetAllBotTeam_Timer, _, TIMER_FLAG_NO_MAPCHANGE);
		g_bResetAllBotTeam = false;
	}
}