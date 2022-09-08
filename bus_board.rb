require 'httparty'
require_relative 'make_url'
require_relative 'response_obj'
require_relative 'api_interactions'

def parse_pos_int(prompt)
  puts prompt
  result_dirty = gets.chomp

  begin
    if Integer(result_dirty)
      result_clean = result_dirty.to_i
      if result_clean > 0
        return result_clean
      else
        puts "Input a positive number, try again:"
        parse_pos_int(prompt)
      end

    end
  rescue ArgumentError
    puts "Not valid integer, try again: "
    parse_pos_int(prompt)
  end
end

loc_coords = get_coords_from_pc()
radius = parse_pos_int("Enter radius: ")

stop_point_hash = find_near_stop_points(loc_coords, radius)

n_found=0

for i in 0..100 do

  break if i+1 >= stop_point_hash.length

  tfl_response_hash = ask_tfl_busses(stop_point_hash[i]["naptanId"])

  if tfl_response_hash == []
    puts "No departures found for stop #{stop_point_hash[i]["naptanId"]} (#{stop_point_hash[i]["commonName"]}, #{i+1})\n"
  else
    tfl_response_obj = StopPointResponseObj.new(tfl_response_hash)

    output_hash = tfl_response_obj.make_out_hash(5)
    puts "For stop: #{stop_point_hash[i]["commonName"]}, which is #{stop_point_hash[i]["distance"].round}m away: (#{i+1})"

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
    n_found += 1
  end
  break if n_found >= 2
end

if n_found == 0
  puts "No stations found within radius"
end

