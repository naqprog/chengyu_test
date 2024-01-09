require 'rails_helper'

RSpec.feature "経路テスト", type: :system, js: true do
  scenario 'goto root' do
    # ルートパスにアクセスできることを確認
    visit root_path
    expect(page).to have_content '成語テストへようこそ'
  end
  scenario 'goto sign-in' do
    # 未ログイン者がルートパスからサインインページに辿れることを確認
    visit root_path
    click_on 'サインアップ(新規作成)'
    expect(page).to have_content 'アカウント録'
  end
end
