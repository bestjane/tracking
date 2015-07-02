//=require rtmap
//=require handle_markers

var map
$(document).ready(function(){
	//initialization
	google.maps.event.addDomListener(window, 'load', initializeMap());
	$("#refresh-panel").click();
	
	//initializeMap();
	initialScroll();
});

	
//--------------------------------------------------------------------------------------------------
	//gather newly added coordinates or add coordinates since begining of mission
function getNewCoordinates(){
	$("#getNewCoordinates").click( function() {
		$.ajax({
			type: "GET",
			url: "/gatherCoordsSince",
			data: {datetime : getLastDatetime(), trackers: getDesiredTrackers(), mission_id: getCurrentMission()},
			dataType: "json",
			success: function(data){
				if(data.length > 0){
					refreshWithNewMarkers2(data,getMap());
					//clearDesiredTrackers(getDesiredTrackers()); //need to check
				}
			}       
		});
	});
}

function getNewTrackers(){
	$("#getNewTrackers").click(function() {
		$.ajax({
			type: "GET",
			url: "/getNewTrackers",
			data: {datetime : getLastDatetime(), trackers: getKnownTrackers(), mission_id: getCurrentMission()}, //!!!!! Be careful, datetime can not begin with 0
			dataType: "json",
			success: function(data){// retrieve an array containing the not yet known trackers
				if(data.length > 0){
					saveNewDesiredTracker(data)//need to check???? need to clear when finish
					saveNewKnownTracker(data);
					alert("Received data: "+data);
				}
			}       
		});
	});
}

function updateMap(){
	$("#map-panel").on("click", "#trackersAndCoordis", function() {
		$.ajax({
			type: "GET",
			url: "/update_map",
			data: {mission_id: getCurrentMission()},
			
			success: function(){
				getNewTrackers()
				getNewCoordinates()
			}       
		});
	});
}

/*=========================== Begin select a mission==================================*/
function choosetMission(){
		missions=getAllCurrentMissions();
		nbmissions=missions.length
		if (nbmissions >1){
			var e = $('#dropdown_select_mission :selected').val();
			if (e=="select_mission"){
				alert("Please choose a correct mission!!!")
			}else{
				saveCurrentMission(e)
				$("#trackersAndCoordis").click();
			}
			//alert(getCurrentMission())//just for debugger
		}
		
}

function selectMissions(){
	$("#map-panel").on("click", "#chooseMission", function() {
		$.ajax({
				type: "GET",
				url: "/getMissions",
				success: function(data){// retrieve an array containing the not yet known trackers
					if(data.length > 0){
						setAllCurrentMissions(data);
						choosetMission();
					}
				}       
			});
	})
}
/*============================End select a mission=========================================*/

//when the panel is displayed
$("#map-panel").ready(function(){
	selectMissions()
	updateMap()
	
  //for all checkboxes of tracker, on click do ...
  $("#map-panel").on("click", "input[name*='tracker']", function() {
      //get id of the checkbox
      var id = $(this).attr('id');
      //if checked
      if($(this).is(':checked')){
      	saveNewDesiredTracker(id);
      }
      //if not checked
      else{
      	removeDesiredTracker(id);
      } 

    })

});



	/*
	$("#getCoordinatesForCurrentMission").click(function(){
		$.ajax({
			type: "GET",
			url: "/getMissionLength",
			dataType: "json",
			success: function(data){
				if(data.length > 0){
					start = data[0];
					end = data[1];
					$.ajax({
						type: "GET",
						url: "/gatherCoordsBetweenDates",
						dataType: "json",
						data: { tstart: start, tend: end},
						success: function(data){
							if(data.length > 0){
								length = data.length;
								refreshWithNewMarkers(data);
							}
						}       
					});
				}
			}       
		});
	});
*/

//-----------------------------------------------------------------