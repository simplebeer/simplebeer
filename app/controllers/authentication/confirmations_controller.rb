module Authentication
  class ConfirmationsController < Devise::ConfirmationsController
    skip_authorization_check
    layout "home"
  end
end
