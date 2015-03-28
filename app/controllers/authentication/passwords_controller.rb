module Authentication
  class PasswordsController < Devise::PasswordsController
    skip_authorization_check
  end
end
