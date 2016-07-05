<!DOCTYPE html>

<html lang="en">

	<cfset loggedOn = FALSE />
	<cfobject component="steamCFC" name="steamAPI"> 
	<cfparam name="formSubmitted" default="0">
	<cfparam name="Form.page" default = "0" />
	<cfparam name="friendsChosen" default = "0">
	<cfparam name="steamID64" default="">
	<cfparam name="steamName" default="">
	<cfparam name="chosen_players" default="default">

	<head>
		<title>Steam thing</title>
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
		<style>
			body {
				color: white;
				background-color: black;
			}

			.img-thumbnail {
				background-color: #00FF00;
				border-color: #00FF00;
				border-bottom-color: #00CC00;
				border-right-color: #00CC00;
			}

			.row-space {
				margin-bottom: 15px;
			}

			.vertical-align {
				vertical-align: text-top;
			}

			ul {
				list-style-type: none;
			}

			.game-column {
				height: 160px;
			}

		</style>
	</head>

	<body>
		<div id="mainContent">
			<cftry>
				<cfswitch expression=#Form.page#>
					<cfcase value="0">
						<div class="col-lg-6 col-lg-offset-3 text-center">
							<br />
							<cfform>
								<h3>Please enter either your 64-bit steam id:</h3>
								<h5>Find it <a href="https://steamid.io/lookup" target="_blank">here</a></h5>
								<br />
								<div class="col-md-6 col-md-offset-3 form-group" style="color:black;">
									<cfinput type="text" class="form-control input-lg" name="steamID64" />
								</div>
								<br />
								<br />
								<br />
								<h3>Or, enter your custom url:</h3>
								<h5>Found at http://steamcommunity.com/id/&lt;customURL&gt;</h5>
								<br />
								<div class="col-md-6 col-md-offset-3 form-group" style="color:black;">
									<cfinput type="text" class="form-control input-lg" name="steamName" />
								</div>
								<br />
								<cfinput type = "hidden" name = "page" value = "1">
								<div class="col-md-6 col-md-offset-3 form-group">
									<cfinput type="submit" class="btn btn-success btn-lg" name="submit" value="Submit"/>
								</div>
							</cfform>
						</div>
					</cfcase>

					<cfcase value="1">
						<div class="col-lg-8 col-lg-offset-2 text-center">
							<cfif steamName NEQ "">
								<cfinvoke 
									component="#steamAPI#" 
									method="getSteamID" 
									returnvariable="their_ID">
									<cfinvokeargument
										name="steamName"
										value="#steamName#">
								</cfinvoke>
								<cfset steamID64 = #their_ID# />
							</cfif>

							<cfinvoke 
								component="#steamAPI#" 
								method="getPlayerInfos" 
								returnvariable="their_profile">
								<cfinvokeargument
									name="steamIDs"
									value="#steamID64#">
							</cfinvoke>
							
							<br />
							<img class="img-thumbnail" src = <cfoutput>#their_profile.players[1].avatarfull#</cfoutput> />
							<h2><cfoutput>#their_profile.players[1].personaname#</cfoutput></h2>

							<br />
								<h3>Your Friends:</h3>
								
								<cfinvoke 
									component="#steamAPI#" 
									method="getFriends" 
									returnvariable="their_friends">
									<cfinvokeargument
										name="steamID"
										value="#steamID64#">
								</cfinvoke>
								
								<!--- <cfdump var="#their_friends#" /> --->
								<cfset tempIDs = "" />
								<cfset count=0 />
								
								<cfloop index="i" array="#their_friends.friends#">
									<cfset count = #count#+1 />
									<cfif #count# GT 90>
										<cfbreak>
									</cfif>
									<cfset tempIDs = #tempIDs#&","&#i.steamid# />
								</cfloop>
								<cfset tempIDs = removeChars(tempIDs,1,1) />

								<cfinvoke 
									component="#steamAPI#" 
									method="getPlayerInfos" 
									returnvariable="friends_profiles">
									<cfinvokeargument
										name="steamIDs"
										value="#tempIDs#">
								</cfinvoke>
								<!--- <cfdump var="#friends_profiles#" /> --->
								<cfform class="form-inline">
									<cfset count = 0 />
									<cfloop index="i" array="#friends_profiles.players#">
										<cfset count = #count#+1 />
										<div class="col-sm-6 row-space">
											<div class="col-sm-4 form-group">
												<div class="checkbox">
													<cfset temp = "check"&#JavaCast("double",count)# />
													<!--- <cfoutput>#JavaCast("double",count)#</cfoutput> --->
													<cfinput type="checkbox" name="chosen_players" value="#i.steamid#" id=#temp# />
													<label for=<cfoutput>#temp#</cfoutput> >
														<img class="img-thumbnail" src = <cfoutput>#i.avatarmedium#</cfoutput> />
													</label>
													
												</div>

											</div>
											<div class="col-sm-8 form-group text-left">
												<h4><cfoutput>#i.personaname#</cfoutput></h4>

											</div>
										</div>
									</cfloop>

									<cfinput type="hidden" name="page" value="2" />
									<cfinput type="hidden" name="steamID64" value=#steamID64# />

									<div class="col-md-12 form-group">	
										<cfinput type="submit" class="btn btn-lg btn-success" name="submit" value="Submit" />
									</div>
									<div class="col-md-12 form-group">	
										<br />
									</div>

								
								</cfform>

							</div>
						</cfcase>

						<cfcase value="2">

							<cfset playerlist = listToArray(chosen_players) />

							<cfinvoke 
								component="#steamAPI#" 
								method="getGames" 
								returnvariable="games">
								<cfinvokeargument
									name="steamID"
									value="#steamID64#">
							</cfinvoke>

							<!--- <cfset playerGames = #games.games# /> --->
							<cfset playerGames = arrayNew(2) />
							<!--- <cfdump var=#games.games# /> --->
							<cfset count = 1 />
							<cfloop index="i" array="#games.games#">
								<cfset playerGames[#count#][1] = #i.appid# />
								<cfset playerGames[#count#][2] = #i.name# />
								<cfset playerGames[#count#][3] = #i.img_logo_url# />
								<cfset count = #count# + 1 />
							</cfloop> 

							<!--- <cfdump var=#playerGames# /> --->



							<cfset allOthersGames = arraynew(2) />
							<cfset count = 1 />
							<cfloop index="i" array="#playerlist#">

								<cfinvoke 
									component="#steamAPI#" 
									method="getGames" 
									returnvariable="games">
									<cfinvokeargument
										name="steamID"
										value="#i#">
								</cfinvoke>

								<cfloop index="j" array="#games.games#">
									<cfset allOthersGames[#count#][1] = #j.appid# />
									<cfset allOthersGames[#count#][2] = #j.name# />
									<cfset allOthersGames[#count#][3] = #j.img_logo_url# />
									<cfset count = #count# + 1 />

								</cfloop>

								

							</cfloop>


							<cfset commonOthersGames = arraynew(2) />

							<cfset tempList = "" />
							<cfloop array="#allOthersGames#" index="i">
								<!--- <cfdump var=#i# /> --->
								<cfset tempList = listAppend(tempList, #i[1]#) />
							</cfloop>

							<!--- <cfdump var=#tempList# /> --->
							
							<cfset countArr = 0 />
							<cfset countList = 0 />
							<cfloop index="i" list="#tempList#" >
								<cfset countArr = #countArr# + 1 />
								<cfset countList = #countList# + 1 />
								<cfset gameID = #i# />
								<cfif (#listValueCount(tempList, gameID)# EQ #ArrayLen(playerlist)#) >
									<cfset tempList = listDeleteAt(tempList, #countList#) />
									<cfset countList = #countList# - 1 />
									<cfset tempArr = allOthersGames[#countArr#] />
									<cfinvoke 
										component="#steamAPI#" 
										method="getGameInfo" 
										returnvariable="gameinfo">
										<cfinvokeargument
											name="appID"
											value=#tempArr[1]#>
									</cfinvoke>
									
									<cfset results = structFindValue(gameinfo, "Multi-player") />
									<cfif #ArrayLen(results)# NEQ 0>
										<cfset tempArr[4] = 1 />
									<cfelse>
										<cfset tempArr[4] = 0 />
									</cfif>
									<cfset results = structFindValue(gameinfo, "Co-op") />
									<cfif #ArrayLen(results)# NEQ 0>
										<cfset tempArr[5] = 1 />
									<cfelse>
										<cfset tempArr[5] = 0 />
									</cfif>

									<cfset temp = ArrayAppend(commonOthersGames,tempArr) />
								</cfif>
							</cfloop>

							<!--- <cfdump var=#commonOthersGames# /> --->

							<cfset yourCommonGames = arraynew(2) />
							<cfset exclusiveGames = arraynew(2) />

							<cfset count = 1 />
							<cfloop index="i" array="#playerGames#" >
								<cfset gameID = #i[1]# />
								<cfloop index="j" array="#commonOthersGames#">
									<cfif ArrayContains(j, gameID) >
										
										<cfset yourCommonGames[#count#][1] = #j[1]# />
										<cfset yourCommonGames[#count#][2] = #j[2]# />
										<cfset yourCommonGames[#count#][3] = #j[3]# />
										<cfset yourCommonGames[#count#][4] = #j[4]# />
										<cfset yourCommonGames[#count#][5] = #j[5]# />
										
										<cfset count = #count# + 1 /> 
									</cfif>
								</cfloop>
							</cfloop>

							<cfset flags = ArrayNew(1) />
							<cfloop index="i" array="#commonOthersGames#">
								<!--- <cfoutput>#ArrayContains(yourCommonGames, i)#</cfoutput> --->
								<cfif NOT ArrayContains(yourCommonGames, #i#) >
									<cfset temp = ArrayAppend(exclusiveGames, #i#) />
								</cfif>
							</cfloop>
							<!--- <cfdump var=#exclusiveGames# /> --->

							<cfif #ArrayLen(yourCommonGames)# NEQ 0 >
								<div class="col-md-10 col-md-offset-1 text-center">
									<h2>Games you all own</h2>

									<br />
									<br />
									<cfloop index="i" array="#yourCommonGames#">
										<cfif #i[4]# EQ 1 OR #i[5]# EQ 1>
											<div class="col-md-4 form-group game-column">
												<cfif #i[3]# NEQ "">
													<cfset tempImg = "http://media.steampowered.com/steamcommunity/public/images/apps/"&i[1]&"/"&#i[3]#&".jpg" />
												<cfelse>
													<cfset tempImg = "img/missing.jpg" />
												</cfif>
													
												<cfset tempURL = "http://store.steampowered.com/app/"&#i[1]# />
												<a href=<cfoutput>#tempURL#</cfoutput> >
													<img class="img-thumbnail" src= <cfoutput>#tempImg#</cfoutput> />
													<h4><cfoutput>#i[2]#</cfoutput></h4>
												</a>
												<cfif #i[4]# EQ 1>
													<h5>Multi-player</h5>
												</cfif>
												<cfif #i[5]# EQ 1>
													<h5>Co-op</h5>
												</cfif>
											</div>
										</cfif>
										
									</cfloop>
								</div>
							<cfelse>
								<h2>You don't own any common games between all the chosen people...</h2>
							</cfif>

							<cfif #ArrayLen(exclusiveGames)# NEQ 0 >
								<div class="col-md-10 col-md-offset-1 text-center">
								<h2>All the chosen friends own these, but not you</h2>

								<br />
								<br />
								<cfloop index="i" array="#exclusiveGames#">
									<cfif #i[4]# EQ 1 OR #i[5]# EQ 1>
										<div class="col-md-4 form-group game-column">
											<cfif #i[3]# NEQ "">
												<cfset tempImg = "http://media.steampowered.com/steamcommunity/public/images/apps/"&i[1]&"/"&#i[3]#&".jpg" />
											<cfelse>
												<cfset tempImg = "img/missing.jpg" />
											</cfif>
												
											<cfset tempURL = "http://store.steampowered.com/app/"&#i[1]# />
											<a href=<cfoutput>#tempURL#</cfoutput> >
												<img class="img-thumbnail" src= <cfoutput>#tempImg#</cfoutput> />
												<h4><cfoutput>#i[2]#</cfoutput></h4>
											</a>
											<cfif #i[4]# EQ 1>
												<h5>Multi-player</h5>
											</cfif>
											<cfif #i[5]# EQ 1>
												<h5>Co-op</h5>
											</cfif>
										</div>
									</cfif>
									
								</cfloop>
							</div>
							</cfif>

						</cfcase>
			
			

				</cfswitch>

				<cfcatch>
					<div class="text-center">
						<p>
							&nbsp;
						</p>
						<h4>
							Sorry, something went wrong
						</h4>
						<br />
						<h5> Common problems:</h5>
						<ul>
							<li><h6>This only works if your profile is set to public.</h6></li>
							<li><h6>Steam's API isn't exactly fast, and I'm making quite a few calls to it.</h6></li>
							<li><h6>Having more than 100 friends will break a few API calls, but it's limited anyway.</h6></li>
						</ul>
					</div>
				</cfcatch>
			</cftry>
			<div class="col-md-12 text-center">
				<h6><a href="http://steampowered.com">Powered by Steam</a></h6>
			</div>
		</div>
	</body>

</html>
