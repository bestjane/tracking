class ScoresController < ApplicationController
	include ScoreHelper

	before_action :get_rob_by_category, only:[:index, :triangular, :stationkeeping, :areascanning, :fleetrace]

  	def index
<<<<<<< HEAD
			
=======
		@teamlist=Team.all
		@TMission = Mission.where(mtype: "TriangularCourse")
		@RMission = Mission.where(mtype: "Race")
		@SKMission = Mission.where(mtype: "StationKeeping")
		@ASMission = Mission.where(mtype: "AreaScanning")
>>>>>>> 8cc2079ba312cc989c9833d3508c599e743a06a5
  	end
	
	  def test
	  end
  
  	def show
  		@score=Score.find(params[:id])
  	end

  	def new
  		@score = Score.new
  	end

  	def create
	    attempt = Attempt.find(params[:score][:attempt_id])
	    mission = Mission.find(attempt.mission_id)
	   	@score = Score.new
	    case mission.mtype
	    when "Race"
	    	temp = getTimeRaceCourse(attempt)
	    	@score.update_attribute(:timecost, temp)
	    when "TriangularCourse"
	    when "StationKeeping"
	    when "AreaScanning"
	   	else
	   	end 


	    @score = Score.new(score_params)

	    respond_to do |format|
	      if @score.save
	        format.html { redirect_to @score, notice: 'Score was successfully created.' }
	        format.json { render :show, status: :created, location: @score }
	      else
	        format.html { render :new }
	        format.json { render json: @score.errors, status: :unprocessable_entity }
	      end
	    end
  	end

  	def update
	    respond_to do |format|
	      if @score.update(score_params)
	        format.html { redirect_to @score, notice: 'score was successfully updated.' }
	        format.json { render :show, status: :ok, location: @score }
	      else
	        format.html { render :edit }
	        format.json { render json: @score.errors, status: :unprocessable_entity }
	      end
	    end
  end

  def destroy
	    @score.destroy
	    respond_to do |format|
	      format.html { redirect_to missions_url, notice: 'score was successfully destroyed.' }
	      format.json { head :no_content }
	    end
  end
  
	def triangular
		# make sure the mission 1 is triangular
		sail_ids=[]
		@sailboatlist.each do |rob|
			sail_ids.push(rob.id)		
		end
		@sail_atts=Attempt.where(mission_id: 1).where(robot_id: sail_ids)		
		microsail_ids=[]
		@microSailboatlist.each do |rob|
			microsail_ids.push(rob.id)		
		end
		@microsail_atts=Attempt.where(mission_id: 1).where(robot_id: microsail_ids)	
		
	end

	def stationkeeping
		# make sure the mission 2 is stationkeeping
		sail_ids=[]
		@sailboatlist.each do |rob|
			sail_ids.push(rob.id)		
		end
		@sail_atts=Attempt.where(mission_id: 2).where(robot_id: sail_ids)		
		microsail_ids=[]
		@microSailboatlist.each do |rob|
			microsail_ids.push(rob.id)		
		end
		@microsail_atts=Attempt.where(mission_id: 2).where(robot_id: microsail_ids)	
		
	end

  def areascanning
		# make sure the mission 3 is areascanning
		sail_ids=[]
		@sailboatlist.each do |rob|
			sail_ids.push(rob.id)		
		end
		@sail_atts=Attempt.where(mission_id: 3).where(robot_id: sail_ids)		
		microsail_ids=[]
		@microSailboatlist.each do |rob|
			microsail_ids.push(rob.id)		
		end
		@microsail_atts=Attempt.where(mission_id: 3).where(robot_id: microsail_ids)	
		
  end

	def fleetrace
		# make sure the mission 4 is fleetrace
		sail_ids=[]
		@sailboatlist.each do |rob|
			sail_ids.push(rob.id)		
		end
		@sail_atts=Attempt.where(mission_id: 4).where(robot_id: sail_ids)		
		microsail_ids=[]
		@microSailboatlist.each do |rob|
			microsail_ids.push(rob.id)		
		end
		@microsail_atts=Attempt.where(mission_id: 4).where(robot_id: microsail_ids)
	end
  	
 	private
		def get_rob_by_category
			@sailboatlist=Robot.where(category: "Sailboat")
			@microSailboatlist=Robot.where(category: "MicroSailboat")
		end

    # Use callbacks to share common setup or constraints between actions.
    def set_score
      @score = Score.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def score_params
      params.require(:score).permit(:attempt_id)
    end
end
