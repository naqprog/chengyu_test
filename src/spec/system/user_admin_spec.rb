require 'rails_helper'

RSpec.feature "【権限関連テスト】", type: :system, js: true do
  scenario '新しく作ったユーザが /admin にアクセスできない' do
    visit root_path
    click_on 'サインアップ(新規作成)'
    fill_in 'メールアドレス', with: 'test_rspec@example.com'
    fill_in 'パスワード', with: 'password'
    fill_in 'パスワードを再度入力してください', with: 'password'
    click_on 'アカウント登録'
    visit rails_admin
    # サイト管理ページに「行けない」のでnot_to
    expect(page).not_to have_content 'サイト管理'
  end
end