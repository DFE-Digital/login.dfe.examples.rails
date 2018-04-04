Rails.application.routes.draw do
  resources :todos
  get '/' => 'todos#homepage'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
