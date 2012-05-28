class ApplicationController < ActionController::Base
  protect_from_forgery

  #before_filter :basic_auth

  protected
  def basic_auth
        authenticate_or_request_with_http_basic do |username, password|
          username == "gatesms" && password == "gatesms"
        end
  end

end
