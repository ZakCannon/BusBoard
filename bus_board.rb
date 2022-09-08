require 'httparty'
require_relative 'make_url'
require_relative 'response_obj'

puts "Enter stop code: "
stop_code = gets.chomp

targ_req = Request.new("api.tfl.gov.uk", "StopPoint", stop_code, "Arrivals")
request_url = targ_req.make_url

dir_response = HTTParty.get(request_url)
response_hash = JSON.parse(dir_response.body)

response_obj = StopPointResponseObj.new(response_hash)

output_hash = response_obj.make_out_hash(5)

for i in 0..4 do

  if i == 0
    puts "Next bus details:"
  end

  if i == 1
         puts "Later bus details"
  end

  arrives_in = output_hash.keys[i]

  puts "Arrives in: #{arrives_in}min"
  puts "LineID: #{output_hash[arrives_in][0]}"
  puts "Destination: #{output_hash[arrives_in][1]}"
  puts "\n"
end

