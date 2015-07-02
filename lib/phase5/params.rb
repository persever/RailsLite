require 'uri'
require 'webrick'

module Phase5
  class Params
    attr_reader :params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}
      @params = @params.merge(route_params)
      parse_www_encoded_form(req.query_string) if req.query_string
      parse_www_encoded_form(req.body) if req.body
    end

    def [](key)
      @params[key.to_s] || @params[key.to_sym]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      URI::decode_www_form(www_encoded_form).each do |pair|
        keys = parse_key(pair[0])
        if keys.length == 1
          @params[keys.first] = pair[1]
        else
          outermost_key = keys.shift
          @params[outermost_key] = create_nested_hashes(keys, pair[1])
        end
      end
    end

    def create_nested_hashes(list, final_value)
        key = list.first
        hash = Hash.new
        if key == list.last
          hash[key] = final_value
        else
          hash[key] = create_nested_hashes(list[1..-1], final_value)
        end
        hash
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
