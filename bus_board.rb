require 'httparty'
require_relative 'make_url'
require_relative 'response_obj'

def get_coords_from_pc(postcode)
  
end


puts "Enter post code (no spaces): "
postcode = gets.chomp
puts "Enter radius: "
radius = gets.chomp

postcodes_req = Request.new("api.postcodes.io", "postcodes/", postcode)
pc_request_url = postcodes_req.make_url

pc_dir_response = HTTParty.get(pc_request_url)
pc_response_hash = JSON.parse(pc_dir_response.body)

loc_coords = [pc_response_hash["result"]["latitude"], pc_response_hash["result"]["longitude"]]

tfl_loc_search_qlist = APIQueryList.new({"stopTypes" => "NaptanPublicBusCoachTram", "modes" => "bus", "radius" => radius, "lon" => loc_coords[1], "lat" => loc_coords[0]})
tfl_loc_search_outlist = tfl_loc_search_qlist.make_list
tfl_loc_search_req = Request.new("api.tfl.gov.uk", "StopPoint", tfl_loc_search_outlist)
tfl_loc_search_url = tfl_loc_search_req.make_url


tfl_loc_search_response = HTTParty.get(tfl_loc_search_url)
tfl_loc_search_hash = JSON.parse(tfl_loc_search_response.body)
stop_point_hash = tfl_loc_search_hash["stopPoints"]

n=0

for i in 0..100 do

  break if i >= stop_point_hash.length

  tfl_req = Request.new("api.tfl.gov.uk", "StopPoint/", stop_point_hash[i]["naptanId"], "Arrivals")
  tfl_request_url = tfl_req.make_url

  tfl_dir_response = HTTParty.get(tfl_request_url)
  tfl_response_hash = JSON.parse(tfl_dir_response.body)

  if tfl_response_hash == []
    puts "No departures found for stop #{stop_point_hash[i]["naptanId"]} (#{stop_point_hash[i]["commonName"]})\n"
  else
    tfl_response_obj = StopPointResponseObj.new(tfl_response_hash)

    output_hash = tfl_response_obj.make_out_hash(5)
    puts "For stop: #{stop_point_hash[i]["commonName"]}, which is #{stop_point_hash[i]["distance"].round}m away:"

    for j in 0..3 do

      if j == 0
        puts "Next bus details:"
      end

      if j == 1
             puts "Later bus details..."
      end

      arrives_in = output_hash.keys[j]


      puts "Arrives in: #{arrives_in}min"
      puts "LineID: #{output_hash[arrives_in][0]}"
      puts "Destination: #{output_hash[arrives_in][1]}"
      puts "\n"

    end
    n += 1
  end
  break if n >= 2
end


