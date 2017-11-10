# README

1. rails new LDAP_Test
2. rails secret
3. create the .rbenv-vars file and put all the config secrets inside
4. installed gems & bundle it
gem "devise"
gem "devise_ldap_authenticatable"
5. rails g controller home index + set routes
root 'home#index', as: 'home_index', via: :all
6. basic html in layouts
7. follow instructions
https://github.com/cschiewek/devise_ldap_authenticatable.wiki.git

Gemfile

gem "devise"
gem "devise_ldap_authenticatable"
run

bundle install
rails g devise:install
rails g devise user
rails g devise:views
rails g devise_ldap_authenticatable:install
rails g migration add_username_to_users username:string:index
bundle exec rake db:migrate
app/controllers/application_controller.rb

before_action :authenticate_user!
before_action :configure_permitted_parameters, if: :devise_controller?

protected

def configure_permitted_parameters
  # devise 4.3 .for method replaced by .permit
  # devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  devise_parameter_sanitizer.for(:sign_in) << :username
end
app/models/user.rb

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :registerable,
     :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true, uniqueness: true

  before_validation :get_ldap_email
  def get_ldap_email
    self.email = Devise::LDAP::Adapter.get_ldap_param(self.username,"mail").first
  end

  # use ldap uid as primary key
  before_validation :get_ldap_id
  def get_ldap_id
    self.id = Devise::LDAP::Adapter.get_ldap_param(self.username,"uidnumber").first
  end

  # hack for remember_token
  def authenticatable_token
    Digest::SHA1.hexdigest(email)[0,29]
  end
end
app/views/devise/sessions/new.html.slim

change :email to :username
config/initializers/devise.rb

Devise.setup do |config|
  # ==> LDAP Configuration
  config.ldap_logger = true
  config.ldap_create_user = true
  config.ldap_update_password = true
  config.ldap_use_admin_to_bind = true

  config.authentication_keys = [ :username ]
  config.password_length = 0..128 # if your ldap has a weak password police
config/ldap.yml

These values are used to connect your app to the ldap server (They are used when you enable them by setting config.ldap_use_admin_to_bind = true in your config/initializers/devise.rb file set.)

host: your.host.fqdn
port: 389 (636 if you want TLS/SSL enabled)
admin_user: "cn=Joe User,ou=people,dc=your-domain,dc=tld"
admin_password: "Joe-Users-Secret-Password" # Best to get this from a ENV variable.
ssl: false (true if you want TLS/SSL enabled)
If your enterprise ldap servers don't allow un-authenticated queries then you need to have ldap_use_admin_to_bind set to true. (You can test to see if you can connect anonymously with an ldap client like JXplorer or Apache Directory Studio. If an anonymous connection fails you will need to use ldap_use_admin_to_bind = true).

These values are used when you're app is running a query for a specific user's authentication information.

attribute: sAMAccountName
base: "ou=people,dc=your-domain,dc=tld"
