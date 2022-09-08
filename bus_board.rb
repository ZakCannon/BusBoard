require 'httparty'

puts "Enter stop code: "
stop_code = gets.chomp


response = HTTParty.get('https://api.tfl.gov.uk/StopPoint/490008660N/Arrivals')
data_hash = JSON.parse(response.body)
puts data_hash[2]["destinationName"]
