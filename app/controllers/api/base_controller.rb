class Api::BaseController < ActionController::Base

  respond_to :json

  layout 'application'

end
