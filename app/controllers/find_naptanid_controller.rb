require 'request_manager'
require 'result_generation'

class FindNaptanidController < ApplicationController
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

    @stop_list_hash = gen_display_hash_nearby_stops(stop_list_hash, 4)
  end
end
