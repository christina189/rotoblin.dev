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

/* Parser settings */
#pragma semicolon 1
#pragma tabsize 4

/* Plugin information */
#define PLUGIN_FULLNAME			"Rotoblin"							// Used when printing the plugin name anywhere
#define PLUGIN_SHORTNAME		"rotoblin"							// Shorter version of the full name, used in file paths, and other things
#define PLUGIN_AUTHOR			"Rotoblin Team"						// Author of the plugin
#define PLUGIN_DESCRIPTION		"A competitive mod for L4D"			// Description of the plugin
#define PLUGIN_VERSION			"1.0.0"								// Version of the plugin
#define PLUGIN_URL				"http://rotoblin.googlecode.com/"	// URL associated with the project
#define PLUGIN_CVAR_PREFIX		PLUGIN_SHORTNAME					// Prefix for plugin cvars
#define PLUGIN_CMD_PREFIX		PLUGIN_SHORTNAME					// Prefix for plugin commands
#define PLUGIN_NATIVES_PREFIX	"Rotoblin"							// Prefix for plugin natives and forwards
#define PLUGIN_TAG				"Rotoblin"							// Plugin tag for chat prints
#define PLUGIN_LIBRARY			PLUGIN_SHORTNAME					// Library name of the plugin
#define PLUGIN_CMD_GROUP		PLUGIN_SHORTNAME					// Command group for plugin commands

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

static			bool:	g_bWasLateLoaded = false;

/*
 * ==================================================
 *                     Includes
 * ==================================================
 */

/*
 * --------------------
 *       Globals
 * --------------------
 */
#include <sourcemod>
#include <sdktools>
#include <l4d_stocks>

#define REQUIRE_EXTENSIONS

#include <sdkhooks>
#include <socket>
#include <left4downtown>

#undef REQUIRE_EXTENSIONS

/*
 * --------------------
 *       Modules
 * --------------------
 */
#include "helpers.sp"
#include "statehelpers.sp"
#include "pause.sp"

/*
 * ==================================================
 *                     Forwards
 * ==================================================
 */

/**
 * Public plugin information.
 */
public Plugin:myinfo = 
{
	name		= PLUGIN_FULLNAME,
	author		= PLUGIN_AUTHOR,
	description	= PLUGIN_DESCRIPTION,
	version		= PLUGIN_VERSION,
	url			= PLUGIN_URL
}

/**
 * Called on pre plugin start.
 *
 * @param myself		Handle to the plugin.
 * @param late			Whether or not the plugin was loaded "late" (after map load).
 * @param error			Error message buffer in case load failed.
 * @param err_max		Maximum number of characters for error message buffer.
 * @return				APLRes_Success for load success, APLRes_Failure or APLRes_SilentFailure otherwise.
 */
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	/* Check plugin dependencies */
	if (!CheckPluginDependencies(error, err_max))
	{
		return APLRes_Failure; // Plugin dependencies failed, refuse load
	}

	g_bWasLateLoaded = late;

	/* Natives */
	CreateNative("Rotoblin_IsEnabled", N_Plugin_IsEnabled);

	/* Library */
	RegPluginLibrary(PLUGIN_LIBRARY);

	return APLRes_Success; // Allow load
}

/**
 * Called on plugin start.
 *
 * @noreturn
 */
public OnPluginStart()
{
	/* Plugin start up routine */
	CreateTrackingConVar(); // Set up public cvar for tracking
	InitializeRandomSeed(); // Initialize random seed
	LoadPluginTranslations(); // Load translations

	/* Modules */
	_StateHelpers_OnPluginStart(); // To be loaded first
	_Pause_OnPluginStart();

	//AutoExecConfig(true, PLUGIN_SHORTNAME);
}

/**
 * Called on plugin end.
 *
 * @noreturn
 */
public OnPluginEnd()
{
	/* Modules */
	_Pause_OnPluginEnd();
}

/*
 * ==================================================
 *                     Public API
 * ==================================================
 */

/**
 * Returns whether the plugin was loaded after map load.
 *
 * @return				True if plugin loaded after map, false otherwise.
 */
stock bool:IsPluginLateLoaded()
{
	return g_bWasLateLoaded;
}

/*
 * ==================================================
 *                    Private API
 * ==================================================
 */

/**
 * Returns plugin dependencies state.
 *
 * @param error			Error message buffer in case load failed.
 * @param err_max		Maximum number of characters for error message buffer.
 * @return				True if plugin can be loaded, false otherwise.
 */
static bool:CheckPluginDependencies(String:error[], err_max)
{
	if (LibraryExists(PLUGIN_LIBRARY))
	{
		strcopy(error, err_max, "Plugin is already loaded");
		return false; // Plugin is already loaded, return
	}

	if (!IsDedicatedServer())
	{
		strcopy(error, err_max, "Plugin only support dedicated servers");
		return false; // Plugin does not support client listen servers, return
	}

	/*decl String:buffer[128];
	GetGameFolderName(buffer, 128);

	if (!StrEqual(buffer, "left4dead", false))
	{
		strcopy(error, err_max, "Plugin only support Left 4 Dead");
		return false; // Plugin does not support this game, return
	}*/

	return true;
}

/**
 * Creates plugin tracking convar.
 *
 * @noreturn
 */
static CreateTrackingConVar()
{
	decl String:buffer[64];
	Format(buffer, sizeof(buffer), "%s Version", PLUGIN_FULLNAME);
	new Handle:cvar = CreateConVarEx("version", PLUGIN_VERSION, buffer, FCVAR_PLUGIN | FCVAR_NOTIFY | FCVAR_DONTRECORD);
	SetConVarString(cvar, PLUGIN_VERSION);
}

/**
 * Load translations needed.
 *
 * @noreturn
 */
static LoadPluginTranslations()
{
	if (!IsTranslationValid("common.phrases")) SetFailState("Missing common.phrases translation file!");
	LoadTranslations("common.phrases");

	if (!IsTranslationValid("core.phrases")) SetFailState("Missing core.phrases translation file!");
	LoadTranslations("core.phrases");

	decl String:file[PLATFORM_MAX_PATH];
	Format(file, PLATFORM_MAX_PATH, "%s.phrases", PLUGIN_SHORTNAME);
	if (!IsTranslationValid(file)) SetFailState("Missing %s translation file!", file);
	LoadTranslations(file);
}

/**
 * Initialize the random seed.
 *
 * @noreturn
 */
static InitializeRandomSeed()
{
	new seed[4];
	seed[0] = GetTime();
	seed[1] = GetTime() / 42;
	decl String:ip[15];
	GetConVarString(FindConVar("ip"), ip, 15);
	ReplaceString(ip, 15, ".", "");
	seed[2] = StringToInt(ip);
	seed[3] = GetConVarInt(FindConVar("hostport"));
	SetURandomSeed(seed, 4);
}