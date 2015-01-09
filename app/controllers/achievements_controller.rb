class AchievementsController < ApplicationController
  before_filter :authenticate_user!
  wrap_parameters format: [:json, :xml]
  respond_to :json
  protect_from_forgery except: [:save_stat,:get_stat]

  def save_achievement
    #Find Game through app token
    client = Client.where(app_token: params[:app_token]).first
    @game = nil
    unless client.nil?
      @game = client.implementation.game
    end

    @user = User.where(id: params[:user_id]).first

    errors = []
    unless @user.nil? or @game.nil?
      stat = Achievement.where(user_id: @user,game_id: @game).first_or_create
      #Set hstore key=>value
      stat.data[params[:key]] = params[:value]

      if stat.save
        status = 201
      else
        status = 400
      end
    else
      if @user.nil?
        errors << "Invalid User"
      end

      if @game.nil?
        errors << "No Game found for App Token"
      end

      status = 400
    end

    respond_to do |format|
      format.json {
        render json: {
          errors: errors
        },
        status: status;
      }
    end
  end

  def get_achievement
    #Find Game through app token
    client = Client.where(app_token: params[:app_token]).first
    @game = nil
    unless client.nil?
      @game = client.implementation.game
    end

    errors = []
    data = nil
    unless @game.nil?
      stat = Achievement.where(user_id: params[:user_id],game_id: @game).first

      unless stat.nil? or stat.data[params[:key]].nil?
        data = stat.data[params[:key]]
        status = :ok
      else
        errors << ["Achievement Does Not Exist For #{params[:key]}"]
        status = 400
      end
    else
      errors << ["Game Not found for app token"]
      status = 400
    end

    respond_to do |format|
      format.json {
        render json: {
          data: data,
          errors: errors
        },
        status: status
      }
    end
  end

end