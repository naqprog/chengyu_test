Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root 'static_pages#index'

  get 'exercise_ask', to: 'exercise#ask'
  post 'exercise_judgement', to: 'exercise#judgement'
  get 'exercise_result', to: 'exercise#result'
end
