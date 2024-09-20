class ForcastController < ApplicationController
  def index
    if @address = params[:address]
      result = HTTPX.get(
        "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/#{CGI.escape @address}", 
        params: {key:Rails.application.config.api_key, 
        include:"current"}
        )
      result.raise_for_status
      @temp = result.json['currentConditions']['temp']
      @resolved_address =  result.json['resolvedAddress']
    end
    # render
  end
end