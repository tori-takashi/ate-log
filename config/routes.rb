Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => 'main_page#index'
  get '/summary/', to: 'summary_page#index'

  resources :main_page, only: [:index] do
  end
end
