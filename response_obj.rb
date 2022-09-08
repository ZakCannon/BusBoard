class StopPointResponseObj
  attr_reader :response_hash

  def initialize(response_hash)
    @response_hash = response_hash
  end

  def get_bus_dest(num)
    return @response_hash[num]["destinationName"]
  end

  def get_bus_lineid(num)
    return @response_hash[num]["lineId"]
  end

  def get_bus_arr_time_UTC(num)
    arr_time =  @response_hash[num]["expectedArrival"]
    return arr_time[11, 8]
  end

  def get_time_to_arr(num)
    return @response_hash[num]["timeToStation"]/60
  end

  def make_out_hash(num)
    output_hash = {}

    for i in 0..(num-1) do
      output_hash[self.get_time_to_arr(i)]= [self.get_bus_lineid(i), self.get_bus_dest(i)]
    end

    output_sorted = output_hash.sort
    output_hash_sorted = output_sorted.to_h

    return output_hash_sorted
  end
end

class PostcodeResponseObj
  def initialize(response_hash)
    @response_hash = response_hash
  end
  def get_lat
    return @response_hash["result"]["latitude"]
  end

  def get_long
    return @response_hash["result"]["longitude"]
  end
end