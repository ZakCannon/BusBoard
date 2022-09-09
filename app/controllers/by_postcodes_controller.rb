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
    postcodes_req = RequestManager.new("api.postcodes.io", "postcodes/", postcode)
    pc_request_url = postcodes_req.make_url

    pc_dir_response = HTTParty.get(pc_request_url)
    pc_response_hash = JSON.parse(pc_dir_response.body)

    pc_response_obj = PostcodeResponse.new(pc_response_hash)
    puts "Successfully got postcode response!"

    begin
      coords = [pc_response_obj.get_lat, pc_response_obj.get_long]
    rescue NoMethodError
      puts "Not a valid postcode"
    end

    stop_point_hash = find_near_stop_points(coords, @radius)
    puts "Successfully found nearby stop points!"

    n_found=0

    web_out_hash = {}

    #looping through the list of stops in stop_point_hash
    for i in 0..100 do
      break if i+1 >= stop_point_hash.length

      #ask tfl when the busses are coming at the stop
      tfl_response_hash = ask_tfl_busses(stop_point_hash[i]["naptanId"])
      puts "Successfully got a response from tfl for bus times!"

      if tfl_response_hash == []
        puts "No busses found for stop #{i}, moving on"
      else
        tfl_response_obj = StopPointResponse.new(tfl_response_hash)

        begin
          output_hash = tfl_response_obj.make_out_hash
        # rescue NoMethodError
        #   puts "here is the error"
        #   puts "Something's gone wrong getting a response from tfl"
        end

        web_out_hash["#{stop_point_hash[i]["commonName"]}"] = output_hash
        puts "leaving #{output_hash} in the web out hash"
        #all these are to make sure we show enough stops
        n_found += 1
      end
      break if n_found >= 2
    end

    puts "finished loop, ready to display"

    @web_out_hash = web_out_hash
    @stop_list =  web_out_hash.keys

    puts "final out hash is #{@web_out_hash}"
    puts "final stop list is #{@stop_list}"
  end
end
