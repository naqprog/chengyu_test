Rails.application.routes.draw do

  get 'responses/create'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root 'static_pages#index'

  get 'exercise_ask', to: 'exercise#ask'
  post 'exercise_judgement', to: 'exercise#judgement'
  get 'exercise_result', to: 'exercise#result'

  get 'exercise_ask_mean', to: 'exercise#ask_mean'
  post 'exercise_judgement_mean', to: 'exercise#judgement_mean'
  get 'exercise_result_mean', to: 'exercise#result_mean'

  get 'settings/edit'
  post 'settings/update'

  resources :questions do
    resource :bookmark, only: %i[create destroy]
  end
end
