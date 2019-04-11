require 'sessions_helper.rb'


class ScenariosController < ApplicationController
  
  before_action :logged_in_user
  before_action :correct_user
  
  def new
    @scenario = Scenario.new
  end
  
  def show
    @scenario = Scenario.find_by_id(params[:id])
    user_dm = []
    @usersprivs = Privilege.where(scenario_id: @scenario)
    @usersprivs.each do |userspriv|
      user_dm[user_dm.length] = userspriv.user_id
    end
    @allDMs = User.where(id: user_dm)
  end
  
  def index
    if decision_maker?
      scenario_dm = []
      @privileges = Privilege.where(user_id: @current_user)
      @privileges.each do |privilege|
        scenario_dm[scenario_dm.length] = privilege.scenario_id
      end
      @scenarios = Scenario.where(id: scenario_dm)
    else 
      @scenarios = Scenario.all
    end
    @scenario = current_user.scenarios.build
  end
  
  def create
    @scenarios = current_user.scenarios.build(scenario_params)
    if @scenarios.save
      flash[:success] = "Scenario created!"
    else
      flash[:success] = "Scenario create failed!"
      @scenarios.create_previlege(current_user.id)
    end
    redirect_to scenarios_url
  end
  
  
  def assign
    if decision_maker?
      redirect_to scenarios_url
    else

    end
  
  end
  
  
  
  def destroy
    if decision_maker?
      @scenario=current_user.scenarios.find_by(id: params[:id])
    else
      @scenarios = Scenario.all
      @scenario = @scenarios.find_by(id: params[:id])
    end
    @scenario.destroy
    flash[:success] = "Scenario deleted"
    redirect_to scenarios_url
  end
  
  def update
    if decision_maker? or admin? and scenario_params
      @scenario = Scenario.find_by_id(params[:id])
      @scenario.update_attributes!(scenario_params)
      flash[:success] = "#{@scenario.name} was successfully updated."
      redirect_to scenario_url
    else
      flash[:warning] = "Content Invalid."
      redirect_to edit_scenario_url(params[:id])
    end
  
  end

  def edit
    @scenario = Scenario.find_by_id(params[:id])
  end
  
  private

    def scenario_params
      params.require(:scenario).permit(:name, :description)
    end
  
    def correct_user
      
      if !admin? && !decision_maker?
        flash[:danger] = "Please log in as correct user."
        redirect_to root_url and return
      end
      
      
    end
  
  
end
