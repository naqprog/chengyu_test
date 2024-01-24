Rails.application.routes.draw do

  # rails admin
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # モデルに紐づくページ

  # ユーザデータ(devise利用)：User
  devise_for :users, controllers: { registrations: 'users/registrations' }

  # 回答データ：Response
  get 'responses/create'
  get 'responses/index', to: 'responses#index'
  get 'responses/daily', to: 'responses#daily'

  # 個人設定データ：Setting
  get 'settings/edit'
  post 'settings/update'

  # 問題データ：Question　お気に入りデータ・既知リスト：Bookmark
  resources :questions, only: %i[index show]  do
    get :search, on: :collection
    resource :bookmark, only: %i[create destroy]
  end

  get 'bookmarks', to: 'bookmarks#index', as: 'bookmarks'

  # モデルに紐付かない

  # 出題ページ
  get 'exercises_ask_chengyu', to: 'exercises#ask_chengyu'
  post 'exercises_judgement_chengyu', to: 'exercises#judgement_chengyu'
  get 'exercises_result_chengyu', to: 'exercises#result_chengyu'
  get 'exercises_ask_mean', to: 'exercises#ask_mean'
  post 'exercises_judgement_mean', to: 'exercises#judgement_mean'
  get 'exercises_result_mean', to: 'exercises#result_mean'

  # 個人設定編集
  get 'profiles', to: 'profiles#index'

  # 静的ページ
  root 'static_pages#index'
  get  'static_pages/explain', as: 'explain'
  get  'static_pages/privacy_policy', as: 'privacy_policy'
  get  'static_pages/sample', as: 'sample'

end
