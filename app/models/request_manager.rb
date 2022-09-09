class RequestManager
  attr_reader :host, :request_code, :args

  def initialize(host, request_code, *args)
    @host = host
    @request_code = request_code
    @args = args
  end

  def make_url
    args_string = @args.join("/")
    fin_url = "https://#{@host}/#{@request_code}#{args_string}"
    return fin_url
  end
end

class APIQueryList
  attr_reader :args
  def initialize(args)
    @args = args
  end

  def make_list
    out_list = "?"
    args.each do |key, value|
      out_list += "#{key}=#{value}&"
    end
    return out_list.delete_suffix!("&")
  end
end

def find_near_stop_points(loc_coords, radius)
  tfl_loc_search_qlist = APIQueryList.new({"stopTypes" => "NaptanPublicBusCoachTram", "modes" => "bus", "radius" => radius, "lon" => loc_coords[1], "lat" => loc_coords[0]})
  tfl_loc_search_outlist = tfl_loc_search_qlist.make_list
  tfl_loc_search_req = RequestManager.new("api.tfl.gov.uk", "StopPoint", tfl_loc_search_outlist)
  tfl_loc_search_url = tfl_loc_search_req.make_url


  tfl_loc_search_response = HTTParty.get(tfl_loc_search_url)
  tfl_loc_search_hash = JSON.parse(tfl_loc_search_response.body)
  stop_point_hash = tfl_loc_search_hash["stopPoints"]

  return stop_point_hash
end

def ask_tfl_busses(naptanId)
  tfl_req = RequestManager.new("api.tfl.gov.uk", "StopPoint/", naptanId, "Arrivals")
  tfl_request_url = tfl_req.make_url

  tfl_dir_response = HTTParty.get(tfl_request_url)
  tfl_response_hash = JSON.parse(tfl_dir_response.body)

  return tfl_response_hash
end