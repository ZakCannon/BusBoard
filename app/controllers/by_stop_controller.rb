require 'request_manager'

class ByStopController < ApplicationController
  def index
  end

  def result
    @naptanId = params[:naptanId]

    def return_view_with_error_message(error_message)
      flash.alert= error_message
      render action: :index
    end

    puts ask_tfl_busses(@naptanId).class

    return return_view_with_error_message("not a valid naptan ID") if ask_tfl_busses(@naptanId).class == Hash

    tfl_response_obj = StopPointResponse.new(ask_tfl_busses(@naptanId))

    output_hash = tfl_response_obj.make_out_hash

    @web_out_hash = output_hash

    flash.each { |type| flash.discard(type) }
  end
end
