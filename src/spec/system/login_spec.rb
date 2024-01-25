require 'rails_helper'

RSpec.feature "【ログインしてできることのテスト】", type: :system, js: true do
  before do
    # 新しいユーザを作る
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  scenario '成語一覧でのお気に入り・既知リストを操作できる' do
    # 成語一覧画面を見る
    visit root_path
    click_on '成語一覧：問題を調べる'
    expect(page).to have_content '一心一意' # 正常な遷移をしているか

    # ブックマークのクリックでデータベースが増加することを確認
    expect {
      find("#bookmark_fav_link_0").click
      sleep(3)
    }.to change(Bookmark, :count).by(1)

    # 増加したデータが本ユーザによるもので、フラグも正常に変動していることを確認
    f_user = User.find_by(email: @user.email)
    f_bookmark = Bookmark.find_by(user_id: f_user.id)
    expect(f_bookmark.favorite).to be true

    # 既知リストに入れるクリックでデータベースが「増加していない」ことを確認
    expect {
      find("#bookmark_known_link_0").click
      sleep(3)
    }.not_to change(Bookmark, :count)

    # 本ユーザで検索すると、既知フラグも正常に変動していることを確認
    k_user = User.find_by(email: @user.email)
    k_bookmark = Bookmark.find_by(user_id: k_user.id)
    expect(k_bookmark.known).to be true
  end

  scenario '問題を解いて、解答画面でお気に入り・既知リストを操作できる。その後各種プロフィールが見れる' do
    visit root_path
    click_on '問題を解く(成語→意味)'
    find('#flexRadio2').choose
    click_on '回答する'
    sleep(3)

    # ブックマークのクリックでデータベースが増加することを確認
    expect {
      click_on '☆お気に入り'
      sleep(3)
    }.to change(Bookmark, :count).by(1)

    # 増加したデータが本ユーザによるもので、フラグも正常に変動していることを確認
    f_user = User.find_by(email: @user.email)
    f_bookmark = Bookmark.find_by(user_id: f_user.id)
    expect(f_bookmark.favorite).to be true

    # 既知リストに入れるクリックでデータベースが「増加していない」ことを確認
    expect {
      click_on '☆既知リスト'
      sleep(3)
    }.not_to change(Bookmark, :count)

    # 本ユーザで検索すると、既知フラグも正常に変動していることを確認
    k_user = User.find_by(email: @user.email)
    k_bookmark = Bookmark.find_by(user_id: k_user.id)
    expect(k_bookmark.known).to be true

    # 成績を見に行ってエラーを起こさない
    visit root_path
    click_on '成績を見る'
    click_on '回答履歴一覧を見る'
    expect(page).to have_content 'あなたの今までの回答記録'
    click_on '戻る'
    click_on 'デイリーの回答履歴を見る'
    expect(page).to have_content 'あなたの今までの回答記録(デイリー)'
    click_on '戻る'

    # お気に入り・既知リストを見に行ってエラーを起こさない
    click_on 'お気に入り一覧を見る'
    expect(page).to have_content 'お気に入り一覧'
    sleep(3)
    click_on '戻る'
    sleep(3)
    click_on '既知リストを見る'
    expect(page).to have_content '既知リスト'
    click_on '戻る'
  end

  scenario '個人設定を変更することができる' do
    visit root_path
    click_on '設定変更'
    choose "繁体字"
    choose "成語を見て、意味を答える"
    choose "お気に入り問題から出題する"
    click_on '変更する'
    sleep(3)

    # 実際にデータベースの設定が変更されていることを確認
    s_user = User.find_by(email: @user.email)
    s_setting = Setting.find_by(user_id: s_user.id)
    expect(s_setting.letter_kind).to eq "fantizi"
    expect(s_setting.test_format).to eq "mean"
    expect(s_setting.test_kind).to eq "favorite"
  end

end
