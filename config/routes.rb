Rails.application.routes.draw do

  root to: 'customers#index'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  
  get 'imports/select_files', to: 'imports#select', as: 'select'
  #post '/upload', to: 'productions#upload'
  post 'imports/upload', to: 'imports#upload'
  get 'imports/results', to: 'imports#results'

  post 'graph/draw', to: 'graphs#draw'

  get 'pdf_format' => 'pdf_formats#show'

  resources :customers do
    resources :products
  end

  resources :products do
    resources :productions
    resources :inspections
  end

  resources :inspections do
    resources :inspect_data
  end

  # resources :inspections

end
