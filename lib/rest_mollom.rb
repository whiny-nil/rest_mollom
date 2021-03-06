require 'oauth'
require 'json'
require 'rest_mollom/mollom_api'
require 'rest_mollom/content_response'
require "rest_mollom/version"

class RMollom
  include RestMollom

  def self.create_test_site(email)
    resp = RMollom.new.api.site(:create, {}, {:email => email})
    if resp["code"] == "200"
      {:public_key => resp["site"]["publicKey"], :private_key => resp["site"]["privateKey"]}
    else
      nil
    end
  end

  attr_accessor :api, :last_response

  #
  # options:
  # :site => api endpoint, default to production url
  # :public_key => mollom public_key
  # :private_key => mollom private_key
  #
  def initialize(options={})
    @debug = options.delete :debug
    @api = MollomApi.new(options)
  end

  def check_content(content={})
    last_response = @api.content(:create, content)
    return nil if last_response[:status] == 'error'

    ContentResponse.new last_response
  end

  def create_captcha(content={})
    content = {:type => 'image'}.merge!(content)
    @api.captcha(:create, content)
  end

  def valid_captcha?(content={})
    last_response = @api.captcha :verify, content
    last_response && last_response['captcha'] && last_response['captcha']['solved'] == '1'
  end


  protected
  def log(message)
    puts message if @debug
  end
end

