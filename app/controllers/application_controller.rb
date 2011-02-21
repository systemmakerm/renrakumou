class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  mobile_filter
  trans_sid

  # helper :all
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password  
end
