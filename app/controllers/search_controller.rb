class SearchController < ApplicationController

  def index
    nconn = Faraday.new(url: "https://developer.nrel.gov") do |f|
    	f.headers['api_key'] = ENV["NREL_API_KEY"]
    end

    nresponse = nconn.get("/api/alt-fuel-stations/v1/nearest.json?fuel_type=ELEC&location=#{params['location']}&api_key=#{ENV["NREL_API_KEY"]}")

    njson = JSON.parse(nresponse.body, symbolize_names: true)

    @station = njson[:fuel_stations].first

    @station_address = njson[:fuel_stations].first[:street_address] + njson[:fuel_stations].first[:city] + njson[:fuel_stations].first[:state] + njson[:fuel_stations].first[:zip]

    gconn = Faraday.new(url: 'https://maps.googleapis.com') do |f|
    	f.headers['key'] = ENV['GMAP_API_KEY']
    end

    gresponse = gconn.get("/maps/api/directions/json?origin=#{params['location']}&destination=#{@station_address}&key=#{ENV['GMAP_API_KEY']}")

    gjson = JSON.parse(gresponse.body, symbolize_names: true)

    @directions = gjson
  end
end
