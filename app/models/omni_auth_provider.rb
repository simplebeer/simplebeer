class OmniAuthProvider < ActiveRecord::Base
  belongs_to :subscriber, polymorphic: true

  validates :name, :subscriber, presence: true

  def access_token
    @access_token ||= begin
      if self.auth_data && credentials = self.auth_data["credentials"]
        credentials["token"]
      end
    end
  end

  def access_token=(token)
    self.auth_data ||= {}
    self.auth_data["credentials"] ||= {}
    self.auth_data["credentials"]["token"] = token
    @access_token = token
  end

  def email
    @email ||= begin
      if self.auth_data && info = self.auth_data["info"]
        info["email"]
      end
    end
  end

  def email=(email)
    self.auth_data ||= {}
    self.auth_data["info"] ||= {}
    self.auth_data["info"]["email"] = email
    @email = email
  end
end
