class BrewsController < ApplicationController
  skip_authorization_check
  before_action :set_brews, only: [:index]

  def index
    @title = "Available Brews"
  end

private

  def brew_names
    @brew_names ||= [
      "Impulse IPA",
      "Hoot n Holler Hefeweizen",
      "Oblivion Oatmeal Stout",
      "Boardwalk Bullet Brown Ale",
      "Sidewinder Saison",
      "Pegasus Pale Ale",
      "Pandemonium Porter",
      "Red Falcon Irish Red Ale",
      "Outlaw Run Old Ale",
      "Boulder Dash Blonde Ale"
    ]
  end

  def set_brews
    @brews = brew_names.map {|name|
      Brew.new(name: name)
    }
  end
end
