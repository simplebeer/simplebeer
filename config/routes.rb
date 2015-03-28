Simplebeer::Application.routes.draw do
  root to: "home#index"
  %w(privacy subscribe terms).each do |page|
    get page, to: "home##{page}", as: page
  end

  resources :brews, :users

  # ---------------------------- DANGER ZONE ---------------------------- #

  # These routes handle user authentication and subscriptions.
  # Only edit these routes if you know what you're doing. Thanks!

  # Devise Routes for Admin Users
  devise_for :admin_users, controllers: {
    sessions: "admin/sessions"
  }

  # Devise Routes for Users
  devise_for :users, controllers: {
    confirmations:      "authentication/confirmations",
    invitations:        "authentication/invitations",
    omniauth_callbacks: "authentication/omniauth_callbacks",
    passwords:          "authentication/passwords",
    registrations:      "authentication/registrations",
    sessions:           "authentication/sessions",
    unlocks:            "authentication/unlocks"
  }

  # LetterOpener for Emails
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/email"
  end

  # Sidekiq Monitoring
  require "sidekiq/web"
  authenticate :admin_user do
    mount Sidekiq::Web => "/sidekiq"
  end
end
