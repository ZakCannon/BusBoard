class Request
  attr_reader :host, :request_code, :args

  def initialize(host, request_code, *args)
    @host = host
    @request_code = request_code
    @args = args
  end

  def make_url
    args_string = @args.join("/")
    fin_url = "https://#{@host}/#{@request_code}#{args_string}"
    return fin_url
  end
end

class APIQueryList
  attr_reader :args
  def initialize(args)
    @args = args
  end

  def make_list
    out_list = "?"
    args.each do |key, value|
      out_list += "#{key}=#{value}&"
    end
    return out_list.delete_suffix!("&")
  end
end