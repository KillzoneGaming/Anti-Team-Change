#include <sourcemod>

stock bool IsValidClient(int client, bool bAlive = false)
{
	return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client) && (!bAlive || IsPlayerAlive(client)));
}

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
    name = "Team Switch Rate Limiter",
    author = "Kryptanyte",
    description = "Limits the rate at which players can switch teams.",
    // Major, Minor, Patch, Build
    version = "1.0.0.12",
    url = "https://steamcommunity.com/id/Kraptanyte"
}

ConVar gCV_TeamJoinBlockTime;

float gF_LastTeamSwitch[MAXPLAYERS+1];
int gI_BlockedTeamSwitchCount[MAXPLAYERS+1];

bool gB_TeamSwitchWatch[MAXPLAYERS+1];

public void OnPluginStart()
{
    gCV_TeamJoinBlockTime = CreateConVar("team_join_block_time", "2.0", "The time in seconds that players will be blocked from joining teams after switching teams. [MUST BE FLOAT (eg 2.0)]");
    
    AddCommandListener(On_JoinTeam, "jointeam");

    RegAdminCmd("sm_tswatch", Command_TeamSwitchWatch, ADMFLAG_CHAT, "Toggle team swap observing");
}

public void OnClientPutInServer(int client)
{
    gF_LastTeamSwitch[client] = 0.0;
    gI_BlockedTeamSwitchCount[client] = 0;
    gB_TeamSwitchWatch[client] = false;
}

public Action On_JoinTeam(int client, char[] command, int args)
{
    if(!IsValidClient(client))
        return Plugin_Continue;

    if(gF_LastTeamSwitch[client] >= (GetEngineTime() - gCV_TeamJoinBlockTime.FloatValue))
    {
        gI_BlockedTeamSwitchCount[client]++;

        /*
        
            tswatch admin command

         */
        for(int i = 1; i <= MaxClients; i++)
        {
            if(IsValidClient(i) && gB_TeamSwitchWatch[i])
            {
                char[] sName = new char[200];
                char[] sSteamID = new char[128];
                GetClientName(client, sName, 200);
                GetClientAuthId(client, AuthId_Steam2, sSteamID, 128);

                PrintToConsole(i, "Player %s (%s) has been blocked from joining teams %i times in the last %f seconds", sName, sSteamID, gI_BlockedTeamSwitchCount[client], gCV_TeamJoinBlockTime.FloatValue);
            }
        }

        // Block teamswitch

        return Plugin_Stop;
    }
    else
    {
        gF_LastTeamSwitch[client] = GetEngineTime();
        gI_BlockedTeamSwitchCount[client] = 0;
    }

    return Plugin_Continue;
}

public Action Command_TeamSwitchWatch(int client, int args)
{
    if(!IsValidClient(client))
        return Plugin_Handled;

    gB_TeamSwitchWatch[client] = !gB_TeamSwitchWatch[client];

    PrintToChat(client, "Team switch watching has been %s", (gB_TeamSwitchWatch[client] ? "enabled" : "disabled"));
    PrintToConsole(client, "Team switch watching has been %s", (gB_TeamSwitchWatch[client] ? "enabled" : "disabled"));

    return Plugin_Handled;
}