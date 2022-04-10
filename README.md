# Anti-Team-Change

This plugin prevents players from switching teams too fast. Primarily to combat players abusing the team switch command to prevent being targeted easily.


ConVar
===

When a player changes team they are prevented from using the jointeam command for a certain amount of time (specified by the ConVar `team_join_block_time`)

By default the `team_join_block_time` ConVar is set to `2.0`. This specifies the cooldown time for using the jointeam command and can be any floating point value. 


Commands
==

To allow admins to monitor and respond to players abusing the jointeam command, there is a togglable feature to log all jointeam blocks to the admins console. 

```
!tswatch - sm_tswatch
```

Example console output:

![Console Image](https://i.imgur.com/J4JmT0F.png)