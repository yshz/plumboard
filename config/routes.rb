Plumboard::Application.routes.draw do

  devise_for :users, :controllers => { registrations: "registrations", sessions: "sessions", omniauth_callbacks: "users/omniauth_callbacks",
      confirmations: "confirmations" } 
  
  devise_scope :user do
    get "signup" => "registrations#new", as: :new_user_registration
    post "signup" => "registrations#create", as: :user_registration
    get "signout" => "sessions#destroy", as: :destroy_user_session
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
    get '/users/auth/:provider/setup' => 'users/omniauth_callbacks#setup'
  end

  # resource defs
  resources :listings, except: [:new, :edit, :update, :create] do
    collection do
      get 'get_pixi_price', 'seller', 'follower', 'sold', 'category', 'local'
    end
  end

  resources :invoices do
    collection do
      get 'sent', 'received', 'autocomplete_user_first_name'
    end
    member do
      get 'pay'
    end
  end

  resources :posts, except: [:new, :edit, :update] do
    collection do
      get 'unread', 'sent', 'mark'
      post 'reply'
    end
  end

  resources :settings, except: [:new, :show, :create, :edit, :destroy, :update]
  resources :users, except: [:new]
  resources :bank_accounts, :card_accounts, except: [:edit, :update]
  resources :sites, only: [:index]

  resources :pixi_posts do
    collection do
      get 'seller', :autocomplete_user_first_name
    end
  end

  resources :pictures, only: [:show, :create, :destroy] do
    member do
      get 'display'
    end
  end

  resources :searches, except: [:new, :edit, :update, :create, :destroy, :show] do
    collection do
      get :autocomplete_listing_title
    end
  end

  resources :post_searches, except: [:new, :edit, :update, :create, :destroy, :show] do
    collection do
      get :autocomplete_post_content
    end
  end

  resources :advanced_searches, except: [:new, :edit, :update, :create, :destroy, :show] do
    collection do
      get :autocomplete_listing_title, :autocomplete_site_name
    end
  end

  resources :comments, only: [:index, :new, :create]
  resources :ratings, only: [:index, :new, :create]

  resources :temp_listings, except: [:index] do
    collection do
      get :autocomplete_site_name, :autocomplete_user_first_name, 'unposted'
    end
    member do
      put 'resubmit', 'submit'
    end
  end

  resources :categories do
    collection do
      get 'inactive', 'manage', :autocomplete_site_name
    end
  end

  resources :pending_listings, except: [:new, :edit, :update, :create, :destroy] do
    member do
      put 'approve', 'deny'
    end
  end
  
  resources :transactions, except: [:destroy, :edit, :update] do
    get 'refund', :on => :member
  end

  resources :inquiries

  namespace :api do
    namespace :v1  do
      resources :sessions, only: [:create, :destroy]
    end
  end

  resources :pages, only: [:index]
  resources :pixi_likes, only: [:create, :destroy]
  resources :saved_listings, only: [:create, :index, :destroy]

  # custom routes
  get "/about", to: "pages#about" 
  get "/privacy", to: "pages#privacy" 
  get "/help", to: "pages#help" 
  get "/terms", to: "pages#terms" 
  get "/howitworks", to: "pages#howitworks" 
  get "/support", to: "inquiries#support" 
  get "/contact", to: "inquiries#new" 
  get "/welcome", to: "pages#welcome" 
  get '/system/:class/:attachment/:id/:style/:filename', :to => 'pictures#asset'
  get '/loc_name', to: "sites#loc_name"
  get '/buyer_name', to: "users#buyer_name"
  get '/states', to: "users#states"
  # get '/photos/:attachment/:id/:style/:filename', :to => 'pictures#display'
  # post "/temp_listings/manage", to: "temp_listings#manage", :via => :post, :as => :manage 
  put '/submit', to: "temp_listings#submit"
  put '/resubmit', to: "temp_listings#resubmit"

  # custom user routes to edit member info
  get "/settings/contact", to: "settings#contact" 
  get "/settings/password", to: "settings#password" 

  # specify routes for devise user after sign-in
  namespace :user do
    root :to => "users#show", :as => :user_root
  end

  # specify root route based on user sign in status
  root to: 'categories#index', :constraints => lambda {|r| r.env["warden"].authenticate? }
  root to: 'pages#home'

  # exception handling
  # match '/*path', :to => 'application#rescue_with_handler'
end
