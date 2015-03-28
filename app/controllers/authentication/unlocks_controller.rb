module Authentication
  class UnlocksController < Devise::UnlocksController
    skip_authorization_check
    layout "home"
  end
end
