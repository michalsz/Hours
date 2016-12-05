require 'net/http'
require 'net/https'
require 'digest'

class Przelewy24
  def self.send_request(action, params)
    url = URI.parse(url_for(action))

    req = Net::HTTP::Post.new(url.path)
    req.form_data = params

    con = Net::HTTP.new(url.host, url.port)
    con.use_ssl = true
    con.verify_mode = OpenSSL::SSL::VERIFY_NONE

    response = con.start { |http| http.request(req) }
    parse_response response.body
  end

  def self.url_for(action, options = {})
    case action
    when :register
      "#{endpoint}/trnRegister"
    when :verify
      "#{endpoint}/trnVerify"
    when :test_connection
      "#{endpoint}/testConnection"
    when :redirect
      "#{endpoint}/trnRequest/#{options[:token]}"
    else
      raise ArgumentError.new("Specified payment action (#{action}) does not exist!")
    end
  end

  def self.merchant_id
    Rails.application.secrets.p24_merchant_id
    'cd8414f7'
     54947
  end

  def self.crc_key
    Rails.application.secrets.p24_crc_key
    'a8b02c501fbdeae7'
  end

  def self.sign(key)
    Digest::MD5.hexdigest(key)
  end

  def self.test_connection
    response = send_request(:test_connection, {
      p24_merchant_id: merchant_id,
      p24_pos_id: merchant_id,
      p24_sign: sign("#{merchant_id}|#{crc_key}")
    })

    if response.error == '0'
      'OK'
    else
      'Connection failed'
    end
  end

  class << self
    def endpoint
      'https://sandbox.przelewy24.pl'
    end

    def parse_response(response)
      ret = OpenStruct.new
      response.split("&").each do |arg|
        line = arg.split('=')
        ret[line[0].strip] = line[1].force_encoding("ISO-8859-2").encode!("UTF-8")
      end
      ret
    end
  end
end
