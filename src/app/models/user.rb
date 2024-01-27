class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { general: Constants.role.general, admin: Constants.role.admin }

  has_one :setting, dependent: :destroy
  accepts_nested_attributes_for :setting

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarks_questions, through: :bookmarks, source: :question
  has_many :responses, dependent: :nullify

  # フラグを調べてtrueにする、もしオブジェクトがなければテーブルにレコードを追加する
  def bookmark(question, flg)
    bookmark = bookmarks.find_or_create_by(question:)
    bookmark.update(flg_to_field(flg) => true)
  end

  # フラグを調べてfalseにする、もし両方falseになったらテーブルからレコードを削除する
  def unbookmark(question, flg)
    # レコードが見つからない場合に例外を発生させる
    bookmark = bookmarks.find_by!(question:)
    # フラグに応じてブックマークの属性を更新
    bookmark.update(flg_to_field(flg) => false)
    # 両方のフラグが false の場合はブックマークを削除
    bookmark.destroy if bookmark.favorite == false && bookmark.known == false
  end

  # 中間テーブルを利用したモデルコレクションから、
  # 引数のQuestionオブジェクトに該当するデータがあれば、そのfavoriteフラグを調べる
  def favorite?(question)
    bookmarks.find_by(question:)&.favorite || false
  end

  # 中間テーブルを利用したモデルコレクションから、
  # 引数のQuestionオブジェクトに該当するデータがあれば、そのknownフラグを調べる
  def known?(question)
    bookmarks.find_by(question:)&.known || false
  end

  # 自分が既知フラグを立てている問題数を返す
  def known_num
    bookmarks.known.count
  end

  # 日数とテスト形式をキーに、現在の回答数をカウントする
  def get_answer_num(input_days = 0, test_format = Constants.test_format.all)
    responses = filter_responses_by_date_and_format(input_days, test_format)
    responses.count
  end

  # 日数とテスト形式をキーに、現在の正答数をカウントする
  def get_correct_num(input_days = 0, test_format = Constants.test_format.all)
    responses = filter_responses_by_date_and_format(input_days, test_format, correct: true)
    responses.count
  end

  # 過去X日間の正答率をパーセントで算出し、回答回数と正答回数をまとめて返す
  # input_daysが0(日間)なら、過去すべて
  def get_correct_answer_rate_data(input_days = 0, test_format = Constants.test_format.all)
    total_responses = get_answer_num(input_days, test_format)
    correct_responses = get_correct_num(input_days, test_format)
    # 条件演算子で0除算回避
    rate = total_responses.zero? ? 0.0 : (correct_responses.to_f / total_responses * 100).round(2)

    [total_responses, correct_responses, rate]
  end

  # 日付を入力して、その日の正答率をパーセントで算出し、回答回数と正答回数をまとめて返す
  def get_daily_correct_answer_rate_data(input_date, test_format = Constants.test_format.all)
    # 指定された日に回答した全レスポンスの数を取得
    total_responses = get_num_for_date(input_date, test_format)

    # 指定された日に正しく回答したレスポンスの数を取得
    correct_responses = get_num_for_date(input_date, test_format, correct: true)

    # 0除算を回避
    rate = total_responses.zero? ? 0.0 : (correct_responses.to_f / total_responses * 100).round(2)

    [total_responses, correct_responses, rate]
  end

  # 指定された日の回答数と正答数を取得するヘルパーメソッド
  def get_num_for_date(input_date, test_format, correct: nil)
    # 日本時間での指定日の始まりと終わりを取得
    jst_start = input_date.in_time_zone('Tokyo').beginning_of_day
    jst_end = input_date.in_time_zone('Tokyo').end_of_day

    # UTCに変換
    utc_start = jst_start.utc
    utc_end = jst_end.utc

    # UTCの範囲を使用してクエリを実行
    scope = responses.where(user_id: id)
    scope = scope.where(test_format:) unless test_format == Constants.test_format.all
    scope = scope.where(created_at: utc_start..utc_end)
    scope = scope.where(correct:) unless correct.nil?
    scope.count
  end

  private

  # 入力されていたフラグ情報を実際のフラグネームに変換する
  def flg_to_field(flg)
    case flg.to_i
    when Constants.bookmark_flg.favorite then :favorite
    when Constants.bookmark_flg.known then :known
    else raise '代入されていたフラグ情報がおかしい'
    end
  end

  # 条件によってresponsesのデータを絞り込む
  def filter_responses_by_date_and_format(input_days, test_format, correct: nil)
    # レスポンスをユーザーIDで絞り込む
    scope = responses.where(user_id: id)

    # test_format が Constants.test_format.all でない場合にテスト形式で絞り込む
    scope = scope.where(test_format:) unless test_format == Constants.test_format.all

    # input_days が 0 でない場合に日付で絞り込む
    scope = scope.where(created_at: time_range(input_days)) unless input_days.zero?

    # correct が指定されている場合（`true` または `false`）に正答フラグで絞り込む
    scope = scope.where(correct:) unless correct.nil?

    scope
  end

  def time_range(days)
    # 日本時間の現在時刻を取得
    now_in_japan = Time.current.in_time_zone('Tokyo')

    # 日本時間でのX日前の始まりの時刻を計算
    start_time = (now_in_japan - days.days).beginning_of_day

    # 日本時間の現在時刻からX日前の始まりまでの範囲を作成
    start_time..now_in_japan
  end
end
