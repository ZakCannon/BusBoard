class ResultGeneration

end


def gen_display_hash(stop_list_hash, len)
  n_found=0
  web_out_hash = {}

  stop_list_hash.each do |stop|

    #ask tfl when the busses are coming at the stop
    tfl_response_hash = ask_tfl_busses(stop["naptanId"])
    tfl_response_obj = StopPointResponse.new(tfl_response_hash)
    output_hash = tfl_response_obj.make_out_hash

    web_out_hash["#{stop["commonName"]}"] = output_hash

    #all these are to make sure we show enough stops
    n_found += 1
    break if n_found >= len
  end

  return web_out_hash
end