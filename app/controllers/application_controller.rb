class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # devise 4.3 .for method replaced by .permit
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
    # devise_parameter_sanitizer.for(:sign_in) << :username
  end
end
