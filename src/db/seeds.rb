require 'csv'

# admin用ユーザデータ

users = [
  {email: 'testj@example.com', password: 'password', role: Constants.role.admin},
  {email: 'testf@example.com', password: 'password', role: Constants.role.admin}
]

user_settings =  [
  {user_id: 1, letter_kind: Constants.letter_kind.jiantizi, test_format: 0, test_kind: 1},
  {user_id: 2, letter_kind: Constants.letter_kind.jiantizi, test_format: 0, test_kind: 0}
]

# 出題用データ
question_file_names = [
  "db/seeds_data/question.csv"
]

# 類義語データ
synonym_file_names = [
  "db/seeds_data/synonym.csv"
]

# 回答データ(サンプルデータ)
response_file_names = [
  "db/seeds_data/response.csv"
]

# -----------------------------------------------------

# adminユーザの作成
# deviseでは find_or_create_by が使えないので独自に実装する

users.each do |user|
  # 一度ユーザーをメールアドレスで検索
  user_data = User.find_by(email: user[:email])
  # 該当ユーザーがいなければ、createする
  if user_data.nil?
    User.create(
      email: user[:email],
      password: user[:password],
      role: user[:role]
    )
  end
end

# 上記で作ったuserのSettingデータ

user_settings.each do |user_setting|
  Setting.find_or_create_by!(user_id: user_setting[:user_id]) do |s|
    s.user_id = user_setting[:user_id]
    s.letter_kind = user_setting[:letter_kind]
    s.test_format = user_setting[:test_format]
  end
end

# 出題データの読み込み

def import_questions_from_csv(file_name)
  CSV.foreach(file_name, headers: true) do |question|
    # 重複データを検知して無視
    Question.find_or_create_by!(chengyu_jianti: question[1]) do |q|
      # idは不要だから[0]は無視
      q.chengyu_jianti = question[1]
      q.chengyu_fanti = question[2]
      q.pinyin = question[3]
      q.mean = question[4]
      q.note = question[5]
      q.other_answer_jianti = question[6]
      q.other_answer_fanti = question[7]
      q.other_answer_pinyin = question[8]
      q.source = question[9]
      q.level = question[10]
      q.created_at = question[11]
      q.updated_at = question[12]
    end
  end
end

question_file_names.each { |file_name| import_questions_from_csv(file_name) }

# 類義語データの読み込み

def import_synonyms_from_csv(file_name)
  CSV.foreach(file_name, headers: true) do |synonym|
    # 重複データを検知して無視
    Synonym.find_or_create_by!(question_id: synonym[1], question_another_id: synonym[2] ) do |s|
      # idは不要だから[0]は無視
      s.question_id = synonym[1]
      s.question_another_id = synonym[2]
      s.created_at = synonym[3]
      s.updated_at = synonym[4]
    end
  end
end

synonym_file_names.each { |file_name| import_synonyms_from_csv(file_name) }

# 回答データ(サンプルデータ)の読み込み

def import_responses_from_csv(file_name)
  CSV.foreach(file_name, headers: true) do |response|
    # 重複データを検知して無視
    Response.find_or_create_by!(created_at: response[4], user_id: response[6], question_id: response[7] ) do |r|
      # idは不要だから[0]は無視
      r.test_format = response[1]
      r.test_kind = response[2]
      r.correct = response[3]
      r.created_at = response[4]
      r.updated_at = response[5]
      r.user_id = response[6]
      r.question_id = response[7]
    end
  end
end

response_file_names.each { |file_name| import_responses_from_csv(file_name) }
