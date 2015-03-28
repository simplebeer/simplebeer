class AdminUser < ActiveRecord::Base
  devise :async, :database_authenticatable, :lockable, :trackable
end
