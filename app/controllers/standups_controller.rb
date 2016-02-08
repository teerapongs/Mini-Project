class StandupsController < ApplicationController

  respond_to :html

  # GET /channels/:channel_id/standups
  def index
    @date     = Date.parse(params[:date]) rescue Date.today
    @channel  = Channel.find(params[:channel_id])
    @standups = @channel.standups.by_date(@date).completed.sort_by { rand }

    respond_with(@standups)
  end

end
