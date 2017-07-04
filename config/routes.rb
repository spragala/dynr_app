Rails.application.routes.draw do

  root to: 'clearance/sessions#new'

  resources :restaurants

end
