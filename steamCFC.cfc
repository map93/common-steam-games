<cfcomponent hint="" displayname="steamCFC" output="false">
  
  <!--- You'll have to get your own Steam API key and enter it below. --->
	<cfset key = "" />

	<cffunction name="getSteamID" description="" returntype="numeric" access="public" output="true">
		<cfargument name="steamName" required="true" type="any">
		<cfset name_url = "http://steamcommunity.com/id/"&steamName&"/?xml=1" />
		<cfhttp url = #name_url#
			result = "player" />
		<cfset temp = XMLParse(#player.Filecontent#) />
		<cfreturn temp.profile.steamID64.XmlText />
	</cffunction>

	<cffunction name="getFriends" description="" returntype="any" access="public" output="true">
		<cfargument name="steamID" required="true" type="any">
		<cfset friends_url = "http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?key="&#key#&"&steamid="&#steamID#&"&relationship=friend&format=json" />
		<cfhttp url = #friends_url#
			result = "friends" />
		<cfset temp = deserializeJSON(friends.filecontent.toString()) />
		<cfreturn temp.friendslist />
	</cffunction>

	<cffunction name="getGames" description="" returntype="any" access="public" output="true">
		<cfargument name="steamID" required="true" type="any">
		<cfset games_url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key="&#key#&"&steamid="&#steamID#&"&format=json&include_appinfo=1&include_played_free_games=1" />
		<cfhttp url = #games_url#
			result = "games" />
		<cfset temp = deserializeJSON(games.filecontent.toString()) />
		<cfreturn temp.response />
	</cffunction>

	<cffunction name="getGameInfo" description="" returntype="any" access="public" output="true">
		<cfargument name="appID" required="true" type="any">
		<cfset games_url = "http://store.steampowered.com/api/appdetails?appids="&#appID# />
		<cfhttp url = #games_url#
			result = "games" />
		<cfset temp = deserializeJSON(games.filecontent.toString()) />
		<cfreturn temp />
	</cffunction>

	<cffunction name="getPlayerInfos" description="" returntype="any" access="public" output="true">
		<cfargument name="steamIDs" required="true" type="any">
		<cfset players_url =  "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key="&#key#&"&steamids="&steamIDs />
		<cfhttp url = #players_url#
			result = "players" />
		<cfset temp = deserializeJSON(players.filecontent.toString()) />
		<cfreturn temp.response />
	</cffunction>

</cfcomponent>
