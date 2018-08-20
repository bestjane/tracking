#SEEDS for WRSC2016
#Independant from the WRSC 2015 database

#SEEDS for production mode
# /!\ BE CAREFUL WHEN CHANGING THIS SEEDS
# In fact this seeds should be loaded only once before the WRSC2016 ! 
# After, forget about using rake db:reset because it will suppress all the previous database !!
# be sure to initialize them by running 'RAILS_ENV=production rake db:seed:seedsWRSC2016'

#Admins

Member.create!(name:  "Yu Cao",
	               email: "Yu.Cao@soton.ac.uk",
	               password:              "foobar",
	               password_confirmation: "foobar",
	               role:     'administrator',
	               activated: true,
	               activated_at: Time.zone.now)

Member.create!(name:  "Thomas Kluyver",
	               email: "thomas@kluyver.me.uk",
	               password:              "foobar",
	               password_confirmation: "foobar",
	               role:     'administrator',
	               activated: true,
	               activated_at: Time.zone.now)

Member.create!(name:  "Capital Seb",
	               email: "sebastien.lemaire@soton.ac.uk",
	               password:              "foobar",
	               password_confirmation: "foobar",
	               role:     'administrator',
	               activated: true,
	               activated_at: Time.zone.now)

#Edition

Edition.create!(name: "WRSC 2018",
				id: 1)

#Missions

	#Fleet Race

	Mission.create!(name:  "Fleet Race Sailboat",
					start: "20180705000000",
					end:   "20180827230000",
             		mtype: "Race",
					category: "Sailboat",
					edition_id: 1,
					id: 1)

	Mission.create!(name:  "Fleet Race Micro Sailboat",
					start: "20180705000000",
					end:   "20180827230000",
             		mtype: "Race",
					category: "MicroSailboat",
					edition_id: 1,
					id: 2)	

	#Station Keeping

	Mission.create!(name:  "Station Keeping Sailboat",
					start: "20180828000000",
					end:   "20180828230000",
             		mtype: "StationKeeping",
					category: "Sailboat",
					edition_id: 1,
					id: 3)

	Mission.create!(name:  "Station Keeping Micro Sailboat",
					start: "20180828000000",
					end:   "20180828230000",
             		mtype: "StationKeeping",
					category: "MicroSailboat",
					edition_id: 1,
					id: 4)

	#Area Scanning

	Mission.create!(name:  "Area Scanning Sailboat",
					start: "20180829000000",
					end:   "20180829230000",
             		mtype: "AreaScanning",
					category: "Sailboat",
					edition_id: 1,
					id: 5)

	Mission.create!(name:  "Area Scanning Micro Sailboat",
					start: "20180829000000",
					end:   "20180829230000",
             		mtype: "AreaScanning",
					category: "MicroSailboat",
					edition_id: 1,
					id: 6)

	#Collision Avoidance

	Mission.create!(name:  "Collision Avoidance Sailboat",
                    start: "20180830000000",
                    end:   "20180830230000",
		     		mtype: "CollisionAvoidance",
					category: "Sailboat",
					edition_id: 1,
					id: 7)

	Mission.create!(name:  "Collision Avoidance Micro Sailboat",
					start: "20180830000000",
					end:   "20180830230000",
		     		mtype: "CollisionAvoidance",
					category: "MicroSailboat",
					edition_id: 1,
					id: 8)

#Markers



#Trackers
i=1
13.times do |n|
	token=i
	Tracker.create!(token:  "#{i}",
         		   description: "Tracker #{i}")
  i=i+1
end