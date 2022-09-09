class StopPointResponse
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

  def make_out_hash
    output_hash_i = {}

    for i in 0..(@response_hash.length-1) do
      output_hash_i[self.get_time_to_arr(i)]= [self.get_bus_lineid(i), self.get_bus_dest(i)]
      puts "successfully grabbed info for bus #{i}"
    end

    output_sorted = output_hash_i.sort
    output_hash = {}

    rank = 0

    output_sorted.each do |entry|
      if entry[0] == 0
        entry[0] = "Now!"
      end

      arr_hash = {
        "arr_time" => entry[0],
        "line_id" => entry[1][0],
        "dest" => entry[1][1]
      }

      output_hash[rank] = arr_hash
      rank += 1
    end

    puts "This is output_hash from the make out hash method #{output_hash}"
    return output_hash
  end
end