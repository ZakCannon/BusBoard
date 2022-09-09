class Postcode < ApplicationRecord
  attr_reader :postcode

  def initialize(response_hash)
    @response_hash = response_hash
    @postcode = response_hash["result"]["postcode"]
  end

  def get_lat
    return @response_hash["result"]["latitude"]
  end

  def get_long
    return @response_hash["result"]["longitude"]
  end

  def get_region
    return @response_hash["result"]["region"]
  end
end
