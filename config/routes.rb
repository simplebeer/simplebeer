Simplebeer::Application.routes.draw do
  # Application Routes
  # These routes will be nested in both the organization and user
  # routes, so you'll be able access either type of subscription
  # with the routes of your application.
  def application_routes

  end

  # Sales Site Routes
  root to: "home#index"
  %w(about contact features pricing privacy terms).each do |page|
    get page, to: "home##{page}", as: page
  end
  resources :contact_messages



  # ---------------------------- DANGER ZONE ---------------------------- #

  # These routes handle user authentication and subscriptions.
  # Only edit these routes if you know what you're doing. Thanks!

  # Devise Routes for Admin Users
  devise_for :admin_users, controllers: {
    sessions: "admin/sessions"
  }

  # Pseudo OAuth Providers
  get "users/auth/:provider", to: "omni_auth_providers#new"

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

  # ------------------------------------------------------------------------- #
  # Routes should be above this line because of :resource_name/:subscriber_id

  # Subscriber Routes
  # These routes handle the billing and organization memberships.
  resources :organizations, :users
  resource :subscriber, path: ":resource_name/:subscriber_id" do
    application_routes
    resources :omni_auth_providers
    resources :organization_memberships, path: "memberships"
    resources :payment_methods

    resource :subscription do
      resource :payment_method
    end
  end
end
