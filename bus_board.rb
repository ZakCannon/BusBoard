require 'httparty'
require_relative 'make_url'

puts "Enter stop code: "
stop_code = gets.chomp

targ_req = Request.new("api.tfl.gov.uk", "StopPoint", stop_code, "Arrivals")
request_url = targ_req.make_url

response = HTTParty.get(request_url)
response_hash = JSON.parse(response.body)

puts response_hash

