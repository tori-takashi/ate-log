Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => 'main_page#index'
  get '/summary/', to: 'summary_page#index'
  post :line_bot, to: 'line_bot#receive'

  resources :main_page, only: [:index] do
  end
end
