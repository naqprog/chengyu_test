require 'rails_helper'

RSpec.feature "【ログイン無しでできることのテスト】", type: :system, js: true do
  scenario '成語一覧画面を見るのに成功' do
    visit root_path
    click_on '成語一覧：問題を調べる'
    expect(page).to have_content '一心一意'
  end
  scenario '意味→成語テスト・簡体字の実施に成功' do
    visit root_path
    find('#chengyutest_jiantizi').click
    find('#answer0').click
    find('#answer1').click
    find('#answer2').click
    find('#answer3').click
    click_on '回答する'
    sleep(3)
    expect(page).to have_content '※ログインするとお気に入り問題等が保存できます' # ログインしてない証
  end
  scenario '意味→成語テスト・繁体字の実施に成功' do
    visit root_path
    find('#chengyutest_fantizi').click
    find('#answer0').click
    find('#answer1').click
    find('#answer2').click
    find('#answer3').click
    click_on '回答する'
    expect(page).to have_content '※ログインするとお気に入り問題等が保存できます' # ログインしてない証
  end
  scenario '成語→意味テスト・簡体字の実施に成功' do
    visit root_path
    find('#meantest_jiantizi').click
    find('#flexRadio2').choose
    click_on '回答する'
    expect(page).to have_content '※ログインするとお気に入り問題等が保存できます' # ログインしてない証
  end
  scenario '成語→意味テスト・繁体字の実施に成功' do
    visit root_path
    find('#meantest_fantizi').click
    find('#flexRadio2').choose
    click_on '回答する'
    expect(page).to have_content '※ログインするとお気に入り問題等が保存できます' # ログインしてない証
  end

end
