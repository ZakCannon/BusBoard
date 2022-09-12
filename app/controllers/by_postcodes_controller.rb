require 'httparty'
require 'request_manager'

class ByPostcodesController < ApplicationController
  def index
  end

  def result
    @postcode = params[:postcode]
    @radius = params[:radius]
    def return_view_with_error_message(error_message)
          flash.alert= error_message
          render action: :index
        end

    pc_response_obj = get_pc_details(@postcode)

    return return_view_with_error_message("Not a valid postcode") unless pc_response_obj

    coords = [pc_response_obj.get_lat, pc_response_obj.get_long]

    stop_list_hash = find_near_stop_points(coords, @radius)

    return return_view_with_error_message("Not a valid radius") unless stop_list_hash

    return return_view_with_error_message("No bus stops found within radius") if stop_list_hash == []

    n_found=0

    web_out_hash = {}

    #looping through the list of stops in stop_list_hash found near the postcode
    stop_list_hash.each do |stop|

      #ask tfl when the busses are coming at the stop
      tfl_response_hash = ask_tfl_busses(stop["naptanId"])
      tfl_response_obj = StopPointResponse.new(tfl_response_hash)
      output_hash = tfl_response_obj.make_out_hash

      web_out_hash["#{stop["commonName"]}"] = output_hash

      #all these are to make sure we show enough stops
      n_found += 1
      break if n_found >= 2
    end

    @web_out_hash = web_out_hash
    @stop_list =  web_out_hash.keys

    flash.each { |type| flash.discard(type) }

  end
end
