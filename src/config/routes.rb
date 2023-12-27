Rails.application.routes.draw do

  get 'responses/create'
  get 'responses/index', to: 'responses#index'
  get 'responses/daily', to: 'responses#daily'

  get 'questions/:id', to: 'questions#show', as: 'question_show'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root 'static_pages#index'

  get 'exercises_ask_chengyu', to: 'exercises#ask_chengyu'
  post 'exercises_judgement_chengyu', to: 'exercises#judgement_chengyu'
  get 'exercises_result_chengyu', to: 'exercises#result_chengyu'

  get 'exercises_ask_mean', to: 'exercises#ask_mean'
  post 'exercises_judgement_mean', to: 'exercises#judgement_mean'
  get 'exercises_result_mean', to: 'exercises#result_mean'

  get 'settings/edit'
  post 'settings/update'

  resources :questions do
    resource :bookmark, only: %i[create destroy]
  end

  get 'profiles', to: 'profiles#index'

end
