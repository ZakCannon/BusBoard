class Request
  attr_reader :host, :request_code, :args

  def initialize(host, request_code, *args)
    @host = host
    @request_code = request_code
    @args = args
  end

  def make_url
    args_string = @args.join("/")
    fin_url = "https://#{@host}/#{@request_code}/#{args_string}"
    return fin_url
  end
end