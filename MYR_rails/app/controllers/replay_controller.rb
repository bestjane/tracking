class ReplayController < ApplicationController
	def show 
	end
	
	def replay_map_panel
		#------------------------------------------------------------------------------------
		#------------ GATHERING ALL THE DESIRED COORDINATES-----------------------------
		@coordinatesCustom = [] #create an empty array where adding desired coordinates
		tab = []
		
		robots=[]
		str = cookies[:robotslist]
		if (str != nil)
			robots = str.split(",")
		end
		if (str != nil) #cannot split nil
			tab = str.split(","); # see what happen if tab only have one element and no ','
		end
		@testRobots=robots
		@testTab=tab
		tabtrack=[]
		
		for i in (0..(tab.length-1)) # skip the loop if tab = []
			@tab0=Robot.find_by_id(tab[i])
			@tracker_id=Tracker.find_by_id(Robot.find_by_id(tab[i]).tracker_id)
			if (Tracker.find_by_id(Robot.find_by_id(tab[i]).tracker_id) !=nil)
				tabtrack.push((Tracker.find_by_id(Robot.find_by_id(tab[i]).tracker_id)).id) #recursively add the coordinates
			end
		end
		@tabtrack=tabtrack		
		for i in (0..(tabtrack.length-1)) # skip the loop if tab = []
			@coordinatesCustom += Coordinate.where(tracker_id: tabtrack[i]); #recursively add the coordinates
		end
		#----------------------------------------------------------------------------------

		#---------------------------- START Limite coordinate -----------------
		mycoordinatesCustom=@coordinatesCustom.reverse
		sortie=[]
		p=1 
		q=1
		nbpts=0
		nbptsmax=125
		tra=0
		nbtra=tabtrack.length
		if mycoordinatesCustom != nil
			for j in 0..mycoordinatesCustom.length-1
				if mycoordinatesCustom[j]!= nil
					if mycoordinatesCustom[j].tracker_id != tra
						tra = mycoordinatesCustom[j].tracker_id
						p=1
						q=1
						nbpts=0
					end
					if nbpts < nbptsmax/nbtra
						if q%p == 0
							sortie=sortie+[mycoordinatesCustom[j]]
							nbpts=nbpts+1
						end
					end
					if q>=60*p
						p=10*p
					end
					q=q+1
				end
			end
		end
		@coordinatesCustom=sortie.reverse
		#---------------------------- FIN Limite coordinate -----------------
		#------------------------------------------------------------------------------------	

		#------------------------------ CREATION OF MARKERS -------------------------------------
		i = 0
		@hash = Gmaps4rails.build_markers(@coordinatesCustom) do |coordinate, marker| #create the @hash with all the coordiantes for gmap4rails
			marker.lat coordinate.latitude
			marker.lng coordinate.longitude
			#permet d avoir une couleur differente par tracker et que le dernier point soit plus grand que les autres
			if @coordinatesCustom[i+1] == nil || @coordinatesCustom[i+1].tracker_id != @coordinatesCustom[i].tracker_id
				marker.picture({
					"url" => "icons/medium"+coordinate.tracker_id.to_s+".png",
					"width" => 25,
					"height" => 29
					})
				#infowindow choisit ce que fait le clic de souris sur un marker
				@coordinate = coordinate
				marker.infowindow render_to_string("infowindow", :collection => @coordinate)
			else
				marker.picture({
					"url" => "icons/small"+coordinate.tracker_id.to_s+".png",
					"width" => 5,
					"height" => 5
					})
			end
			url= Team.find_by_id(Robot.find_by_tracker_id(coordinate.tracker_id).team_id).logo	
			i = i+1
		end
		#------------------------------------------------------------------------------------

		#----------------------- CREATION OF POLYLINES  ------------------------------
		# colors:     rouge  , bleu   , vert foncé, orange  , noir    , mauve    , blanc  , rose  , vert fluo , rouge foncé, jaune , turquoise
		@colors = [nil,'#CC0000','#0000CC','#003300','#FF3300','#000000','#660099','#FFFFFF','#CC00CC','#00CC00','#660000','#FFFF00','#33FFFF']
		
		j = 0 #indice de boucle pour le parcours de @coordinatesCustom
		@hash2 = []
		
		for j in 0 ..@coordinatesCustom.length-1
			if @hash2[@coordinatesCustom[j].tracker_id] == nil
				@hash2[@coordinatesCustom[j].tracker_id] = []
				@hash2[@coordinatesCustom[j].tracker_id].push({lat: @coordinatesCustom[j].latitude.to_s, lng: @coordinatesCustom[j].longitude.to_s})
			else
				@hash2[@coordinatesCustom[j].tracker_id].push({lat: @coordinatesCustom[j].latitude.to_s, lng: @coordinatesCustom[j].longitude.to_s})
			end
		end
	end
	#------------------------------------------------------------------------------------
	
	def choice_teams
			#-------------- HTML PRESENTATION ----------------------------------
		#-------- variables d instance passees a la vue -------------------
		
		@teams=Team.all #all the teams
		#creation of @tabteams to help for the generation of the HTML code 
		@testCookies=cookies
		@strteams = cookies[:teamslist]
		if (@strteams != nil) #cannot split nil
			@tabteams = @strteams.split(",");
			@tabteams.sort! #to display the robot in the order of the teams
		else
			@tabteams = []
		end	
		
		#--------------------------------------------------------------------
	end
	
	def choice_robots
 	#------------------------------------------------------------------------------------
		#-------------- HTML PRESENTATION ----------------------------------
		#-------- variables d instance passees a la vue -------------------
		@teams=Team.all #all the teams

		#creation of @tabteams to help for the generation of the HTML code 
		@strteams = cookies[:teamslist]
		if (@strteams != nil) #cannot split nil
			@tabteams = @strteams.split(",");
			@tabteams.sort! #to display the robot in the order of the teams
		else
			@tabteams = []
		end	
		#--------------------------------------------------------------------

		#----------make sure that no robot from an unchecked team is checked---------------
		possiblerobots = []
		for i in 0..@tabteams.length-1
			possiblerobots += Robot.where(team_id: @tabteams[i]) #a list of all the robots to be displayed
		end

		possiblerobots2 = []
		possiblerobots.each do |robot|
			possiblerobots2.push(robot.id)#a list of all the id of the robot to be displayed
		end

		robots=[]
		str = cookies[:robotslist]
		if (str != nil)
			robots = str.split(",")
		end
		
		todelete = []
		for i in 0..robots.length-1
			if (possiblerobots2.index(robots[i].to_i) == nil )#if a robot is present despite the fact it should not be (team unchecked)
				todelete.push(robots[i])
			end
		end
		
		robots = robots - todelete #remove (and not delete ...) the undesired robot

		cookies[:robotslist] = robots.join(",") # modify the cookie after having delete undesired robots
		#----------------------------------------------------------------------------------
 	end
 	
 	def choice_missions
 		#--------------Help the generation of html for missions----------------------------
		strrobots = cookies[:rrobotslist]
		if (strrobots != nil)
			@indrobots = strrobots.split(",") #list of index of the robots to diplay
		else
			@indrobots = []
		end	

		strteams = cookies[:rteamslist] 
		if (strteams != nil) #cannot split nil
			@indteams = strteams.split(","); #list of index of the team to display
		else
			@indteams = []
		end	

		@strmissions = cookies[:rmissionslist]
		#----------------------------------------------------------------------------------
 	end
 	
 	def infowindow
 	end

end
