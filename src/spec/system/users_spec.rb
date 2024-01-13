require 'rails_helper'

RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.feature "【サインイン関連テスト】", type: :system, js: true do

  # ルートパスからサインアップからユーザが作れて、すぐアカウント削除できることを確認
  scenario 'sign-up and quit' do
    visit root_path
    click_on 'サインアップ(新規作成)'
    fill_in 'メールアドレス', with: 'test_rspec@example.com'
    fill_in 'パスワード', with: 'password'
    fill_in 'パスワードを再度入力してください', with: 'password'
    expect{
      click_on 'アカウント登録'
      expect(page).to have_content 'アカウント登録が完了しました。登録されたメールアドレスにメールをお送りしていますので、ご確認ください。'
    }.to change(User, :count).by(1).and change(Setting, :count).by(1)
    # 作ったアカウントを削除する
    click_on '設定変更'
    click_on 'メールアドレス・パスワード変更・アカウント削除'
    expect{
      click_on 'アカウント削除'
      expect(page.accept_confirm).to eq "本当にアカウントを削除しますか？\n保存されていたデータは全て利用できなくなります"
      expect(page).to have_content 'アカウントを削除しました。またのご利用をお待ちしております。'
    }.to change(User, :count).by(-1).and change(Setting, :count).by(-1)
  end

  # 同じメールアドレスで２人のユーザを作ろうとすると失敗する
  scenario 'sign-up same email user' do
    visit root_path
    # テストユーザーをまず作る
    click_on 'サインアップ(新規作成)'
    fill_in 'メールアドレス', with: 'test_rspec@example.com'
    fill_in 'パスワード', with: 'password'
    fill_in 'パスワードを再度入力してください', with: 'password'
    click_on 'アカウント登録'
    # 作ったらログアウトする
    click_on 'ログアウト'
    sleep(3)

    # ルートパス・サインアップから同一メールアドレスでユーザを作ってみる
    visit root_path
    click_on 'サインアップ(新規作成)'
    fill_in 'メールアドレス', with: 'test_rspec@example.com'
    fill_in 'パスワード', with: 'password'
    fill_in 'パスワードを再度入力してください', with: 'password'
    # ユーザが作れなかった
    expect{
      click_on 'アカウント登録'
      expect(page).to have_content 'メールアドレスはすでに存在します'
    }.to not_change(User, :count).and not_change(Setting, :count)
  end

end
