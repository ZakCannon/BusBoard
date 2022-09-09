require 'httparty'
require 'request_manager'

class ByPostcodesController < ApplicationController
  def index
  end

  def result
    @postcode = params[:postcode]
    @radius = params[:radius]

    # if @postcode.match(/\W/)
    #   puts "Not a valid postcode"
    #   get_coords_from_pc()
    # end

    postcode = @postcode.split(" ")
    postcode = postcode.join()
    postcodes_req = Request.new("api.postcodes.io", "postcodes/", postcode)
    pc_request_url = postcodes_req.make_url

    pc_dir_response = HTTParty.get(pc_request_url)
    pc_response_hash = JSON.parse(pc_dir_response.body)

    pc_response_obj = PostcodeResponse.new(pc_response_hash)

    begin
      coords = [pc_response_obj.get_lat, pc_response_obj.get_long]
    # rescue NoMethodError
    #   puts "Not a valid postcode"
    #   get_coords_from_pc()
    end

    @coords = coords

    tfl_loc_search_qlist = APIQueryList.new({"stopTypes" => "NaptanPublicBusCoachTram", "modes" => "bus", "radius" => @radius, "lon" => @coords[1], "lat" => @coords[0]})
    tfl_loc_search_outlist = tfl_loc_search_qlist.make_list
    tfl_loc_search_req = Request.new("api.tfl.gov.uk", "StopPoint", tfl_loc_search_outlist)
    tfl_loc_search_url = tfl_loc_search_req.make_url


    tfl_loc_search_response = HTTParty.get(tfl_loc_search_url)
    tfl_loc_search_hash = JSON.parse(tfl_loc_search_response.body)
    stop_point_hash = tfl_loc_search_hash["stopPoints"]

    @stop_point_hash = stop_point_hash

    n_found=0

    out_array = []

    #looping through the list of stops in stop_point_hash
    for i in 0..100 do

      break if i+1 >= stop_point_hash.length

      #ask tfl when the busses are coming at the stop
      tfl_req = Request.new("api.tfl.gov.uk", "StopPoint/", stop_point_hash[i]["naptanId"], "Arrivals")
      tfl_request_url = tfl_req.make_url

      tfl_dir_response = HTTParty.get(tfl_request_url)
      tfl_response_hash = JSON.parse(tfl_dir_response.body)

      if tfl_response_hash == []
        out_array.push( "No departures found for stop #{stop_point_hash[i]["naptanId"]} (#{stop_point_hash[i]["commonName"]}, #{i+1})\n")
      else
        tfl_response_obj = StopPointResponse.new(tfl_response_hash)

        begin
          output_hash = tfl_response_obj.make_out_hash(4)
        # rescue NoMethodError
        #   puts "here is the error"
        #   puts "Something's gone wrong getting a response from tfl"
        end

        out_array.push("For stop: #{stop_point_hash[i]["commonName"]}, which is #{stop_point_hash[i]["distance"].round}m away: (#{i+1})")

        #puts out the bus info if there is any
        for j in 0..3 do

          if j == 0
            out_array.push(puts "Next bus details:")
          end

          if j == 1
            out_array.push("Later bus details...")
          end

          arrives_in = output_hash.keys[j]

          out_array.push("Arrives in: #{arrives_in}min\nLineID: #{output_hash[arrives_in][0]}\nDestination: #{output_hash[arrives_in][1]}\n")
        end

        #all these are to make sure we show enough stops
        n_found += 1
      end
      break if n_found >= 2
    end

    if n_found == 0
      out_array.push("No departures found within radius")
    end

    out_str = out_array.join("\n")
    @out_str = out_str

  end
end
