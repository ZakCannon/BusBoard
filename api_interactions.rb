require 'httparty'
require_relative 'response_obj'

def get_coords_from_pc()
  puts "Enter post code: "
  postcode = gets.chomp

  if postcode.match(/\W/)
    puts "Not a valid postcode"
    get_coords_from_pc()
  end

  postcode = postcode.split(" ")
  postcode = postcode.join()
  postcodes_req = Request.new("api.postcodes.io", "postcodes/", postcode)
  pc_request_url = postcodes_req.make_url

  pc_dir_response = HTTParty.get(pc_request_url)
  pc_response_hash = JSON.parse(pc_dir_response.body)

  pc_response_obj = PostcodeResponseObj.new(pc_response_hash)

  begin
    coords = [pc_response_obj.get_lat, pc_response_obj.get_long]
    return coords
  rescue NoMethodError
    puts "Not a valid postcode"
    get_coords_from_pc()
  end
end

def find_near_stop_points(loc_coords, radius)
  tfl_loc_search_qlist = APIQueryList.new({"stopTypes" => "NaptanPublicBusCoachTram", "modes" => "bus", "radius" => radius, "lon" => loc_coords[1], "lat" => loc_coords[0]})
  tfl_loc_search_outlist = tfl_loc_search_qlist.make_list
  tfl_loc_search_req = Request.new("api.tfl.gov.uk", "StopPoint", tfl_loc_search_outlist)
  tfl_loc_search_url = tfl_loc_search_req.make_url


  tfl_loc_search_response = HTTParty.get(tfl_loc_search_url)
  tfl_loc_search_hash = JSON.parse(tfl_loc_search_response.body)
  stop_point_hash = tfl_loc_search_hash["stopPoints"]

  return stop_point_hash
end

def ask_tfl_busses(naptanId)
  tfl_req = Request.new("api.tfl.gov.uk", "StopPoint/", naptanId, "Arrivals")
  tfl_request_url = tfl_req.make_url

  tfl_dir_response = HTTParty.get(tfl_request_url)
  tfl_response_hash = JSON.parse(tfl_dir_response.body)

  return tfl_response_hash
end
