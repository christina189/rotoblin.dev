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

/*
 * ==================================================
 *                     Includes
 * ==================================================
 */

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

/*
 * --------------------
 *       Private
 * --------------------
 */

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
public _ModuleName_OnPluginStart()
{
	g_iDebugChannel = Debug_AddChannel("ModuleName");

	HookGlobalForward(GFwd_OnPluginEnabled, _MN_OnPluginEnabled);
	HookGlobalForward(GFwd_OnPluginDisabled, _MN_OnPluginDisabled);

	Debug_PrintTextEx("Module start");
}

/**
 * Called on plugin end.
 *
 * @noreturn
 */
public _ModuleName_OnPluginEnd()
{
	
	Debug_PrintTextEx("Module end");
}

/**
 * Called on plugin enabled.
 *
 * @noreturn
 */
public _MN_OnPluginEnabled()
{
	
	Debug_PrintTextEx("Module enabled");
}

/**
 * Called on plugin disabled.
 *
 * @noreturn
 */
public _MN_OnPluginDisabled()
{
	
	Debug_PrintTextEx("Module disabled");
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