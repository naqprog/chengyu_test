FactoryBot.define do
  factory :user do
    email { "test_rspec@example.com" }
    password { "password" }
    password_confirmation { "password" }

    # Userインスタンスがcreateされた後にSettingも作成する
    after(:create) do |user|
      create(:setting, user: user)
    end
  end

  factory :setting do
    user # これによりSettingのインスタンスが作成されるときに関連するUserも同時に作成される
    letter_kind { 0 }
    test_format { 0 }
    test_kind { 0 }
  end
end

