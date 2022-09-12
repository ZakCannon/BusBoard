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

def ask_api(request)
  req_url = request.make_url
  begin
    req_response = HTTParty.get(req_url)
    return JSON.parse(req_response.body)
  rescue URI::InvalidURIError
    return nil
  end
end


def find_near_stop_points(loc_coords, radius)
  tfl_loc_search_qlist = APIQueryList.new({"stopTypes" => "NaptanPublicBusCoachTram", "modes" => "bus", "radius" => radius, "lon" => loc_coords[1], "lat" => loc_coords[0]})
  tfl_loc_search_outlist = tfl_loc_search_qlist.make_list
  tfl_loc_search_req = RequestManager.new("api.tfl.gov.uk", "StopPoint", tfl_loc_search_outlist)

  tfl_loc_search_hash = ask_api(tfl_loc_search_req)
  if tfl_loc_search_req != nil
    stop_point_hash = tfl_loc_search_hash["stopPoints"]
    return stop_point_hash
  else
    return nil
  end

end

def ask_tfl_busses(naptanId)
  tfl_req = RequestManager.new("api.tfl.gov.uk", "StopPoint/", naptanId, "Arrivals")
  return ask_api(tfl_req)
end


def get_pc_details(postcode1)
  postcode = postcode1.split(" ")
  postcode = postcode.join()
  postcodes_req = RequestManager.new("api.postcodes.io", "postcodes/", postcode)

  pc_response_hash = ask_api(postcodes_req)
  if pc_response_hash == nil
    return nil
  end

  if pc_response_hash["status"] == 404
    return nil
  else
    return PostcodeResponse.new(pc_response_hash)
  end
end