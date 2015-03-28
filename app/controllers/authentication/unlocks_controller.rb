module Authentication
  class UnlocksController < Devise::UnlocksController
    skip_authorization_check
  end
end
