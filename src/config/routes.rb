Rails.application.routes.draw do

  # rails admin
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # モデルに紐づくページ

  # ユーザデータ(devise利用)：User
  devise_for :users, controllers: { registrations: 'users/registrations' }

  # 回答データ：Response
  get 'responses/create'
  get 'responses/index', to: 'responses#index'

  resources :responses_daily, only: [:index]

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
  resources :exercises_chengyu, only: [:new, :create]
  get 'exercises_chengyu', to: 'exercises_chengyu#show', as: 'exercises_chengyu_show'
  resources :exercises_mean, only: [:new, :create]
  get 'exercises_mean', to: 'exercises_mean#show', as: 'exercises_mean_show'

  # 個人設定編集
  get 'profiles', to: 'profiles#index'

  # 静的ページ
  root 'static_pages#index'
  get  'static_pages/explain', as: 'explain'
  get  'static_pages/privacy_policy', as: 'privacy_policy'
  get  'static_pages/sample', as: 'sample'

end
