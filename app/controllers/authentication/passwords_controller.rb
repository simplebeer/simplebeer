module Authentication
  class PasswordsController < Devise::PasswordsController
    skip_authorization_check
    layout "home"
  end
end
