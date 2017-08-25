Rails.application.routes.draw do

  constraints Clearance::Constraints::SignedIn.new do
    root to: 'restaurants#index', as: :signed_in_root
  end

  constraints Clearance::Constraints::SignedOut.new do
    root to: 'clearance/sessions#new'
  end

  resources :restaurants
  post '/restaurants/search' => 'restaurants#pick_rest', as: "search_rest"

end
