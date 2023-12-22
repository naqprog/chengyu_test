Rails.application.routes.draw do

  get 'responses/create'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root 'static_pages#index'

  get 'exercise_ask_chengyu', to: 'exercise#ask_chengyu'
  post 'exercise_judgement_chengyu', to: 'exercise#judgement_chengyu'
  get 'exercise_result_chengyu', to: 'exercise#result_chengyu'

  get 'exercise_ask_mean', to: 'exercise#ask_mean'
  post 'exercise_judgement_mean', to: 'exercise#judgement_mean'
  get 'exercise_result_mean', to: 'exercise#result_mean'

  get 'settings/edit'
  post 'settings/update'

  resources :questions do
    resource :bookmark, only: %i[create destroy]
  end
end
