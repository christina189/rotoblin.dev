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

static			Handle:	g_hEnableCvar				= INVALID_HANDLE;
static			bool:	g_bIsPluginEnabled			= false;
static			Handle: g_hGFwd_OnPluginEnabled		= INVALID_HANDLE;
static			Handle: g_hGFwd_OnPluginDisabled	= INVALID_HANDLE;

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
public _PluginState_OnPluginStart()
{
	decl String:buffer[128];

	Format(buffer, sizeof(buffer), "%s_OnEnabled", PLUGIN_NATIVES_PREFIX);
	g_hGFwd_OnPluginEnabled = CreateGlobalForward(buffer, ET_Ignore);

	Format(buffer, sizeof(buffer), "%s_OnDisabled", PLUGIN_NATIVES_PREFIX);
	g_hGFwd_OnPluginDisabled = CreateGlobalForward(buffer, ET_Ignore);

	Format(buffer, sizeof(buffer), "Sets whether %s is enabled", PLUGIN_FULLNAME);
	g_hEnableCvar = CreateConVarEx("enable", "0", buffer, FCVAR_PLUGIN | FCVAR_NOTIFY);

	HookGlobalForward(GFwd_OnAllPluginsLoaded, _PS_OnAllPluginsLoaded);
}

/**
 * Called on all plugins loaded.
 *
 * @noreturn
 */
public _PS_OnAllPluginsLoaded()
{
	SetPluginState(GetConVarBool(g_hEnableCvar));
	HookConVarChange(g_hEnableCvar, _PS_Enable_CvarChange);
}

/**
 * Called on enable cvar changed.
 *
 * @param convar		Handle to the convar that was changed.
 * @param oldValue		String containing the value of the convar before it was changed.
 * @param newValue		String containing the new value of the convar.
 * @noreturn
 */
public _PS_Enable_CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	SetPluginState(GetConVarBool(convar));
}

/**
 * Native function for Rotoblin_IsEnabled. Returns whether plugin is enabled.
 * 
 * @param plugin		Handle to calling plugin.
 * @param numParams		Number of parameters.
 * @return				True if enabled, false otherwise.
 */
public N_Plugin_IsEnabled(Handle:plugin, numParams)
{
	return _:g_bIsPluginEnabled;
}

/*
 * ==================================================
 *                     Public API
 * ==================================================
 */

/**
 * Returns plugin state.
 * 
 * @return				True if plugin is enabled, false otherwise.
 */
stock bool:IsPluginEnabled() return g_bIsPluginEnabled;

/*
 * ==================================================
 *                    Private API
 * ==================================================
 */

/**
 * Sets current plugin state.
 * 
 * @param enabled		Whether the plugin is enabled.
 * @noreturn
 */
static SetPluginState(bool:enabled)
{
	if (g_bIsPluginEnabled == enabled) return; // No change in plugin state, return
	g_bIsPluginEnabled = enabled;

	if (enabled)
	{
		Call_StartForward(g_hGFwd_OnPluginEnabled);
	}
	else
	{
		Call_StartForward(g_hGFwd_OnPluginDisabled);
	}
	Call_Finish();
}