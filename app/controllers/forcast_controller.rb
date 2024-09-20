class ForcastController < ApplicationController
  def index
    if address
      raise Address::IncompleteAddressError.new(address, 'Zip Code') unless address.zip.present?
      result = Rails.cache.fetch "forecast/by_zip/#{@address.zip}", expires_in: 30.minutes do
        @fresh_cache = true
        lookup_address(@address).tap do |result|
          @resolved_address =  result['resolvedAddress']
        end
      end

      @temp = result['currentConditions']['temp']
    end
    # render
  rescue Address::IncompleteAddressError => error
    @error = error
    @fresh_cache = true
  end

  def lookup_address(address)
    HTTPX.get(
        "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/#{CGI.escape address}",
        params: { key: Rails.application.config.api_key,
        include: "current" }
        ).tap(&:raise_for_status).json
  end

  def address
    return @address unless @address.nil?
    return unless params.include?(:address)
    @address = Address.new(params.fetch(:address))
  end
end
