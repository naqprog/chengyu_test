require 'rails_helper'

RSpec.feature "【ログイン無しでできることのテスト】", type: :system, js: true do
  scenario 'look chengyu' do
    # 成語一覧画面を見る
    visit root_path
    click_on '成語一覧：問題を調べる'
    expect(page).to have_content '一心一意'
  end
  scenario 'test chengyu jiantizi' do
    # 成語を聞く・簡体字　でテストを実施
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
  scenario 'test chengyu fantizi' do
    # 成語を聞く・繁体字　でテストを実施
    visit root_path
    find('#chengyutest_fantizi').click
    find('#answer0').click
    find('#answer1').click
    find('#answer2').click
    find('#answer3').click
    click_on '回答する'
    expect(page).to have_content '※ログインするとお気に入り問題等が保存できます' # ログインしてない証
  end
  scenario 'test mean jiantizi' do
    # 意味を聞く・簡体字　でテストを実施
    visit root_path
    find('#meantest_jiantizi').click
    find('#flexRadio2').choose
    click_on '回答する'
    expect(page).to have_content '※ログインするとお気に入り問題等が保存できます' # ログインしてない証
  end
  scenario 'test mean fantizi' do
    # 意味を聞く・繁體字　でテストを実施
    visit root_path
    find('#meantest_fantizi').click
    find('#flexRadio2').choose
    click_on '回答する'
    expect(page).to have_content '※ログインするとお気に入り問題等が保存できます' # ログインしてない証
  end

end
