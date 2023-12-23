class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { general: Constants.role.general, admin: Constants.role.admin }

  has_one :setting, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarks_questions, through: :bookmarks, source: :question

  # フラグを調べてtrueにする、もしオブジェクトがなければテーブルにレコードを追加する
  def bookmark(question, flg)
    # レコードがすでにある？
    if !bookmarks_questions.include?(question)
      # 無いなら作る
      bookmarks_questions << question
    end

    # レコードのフラグ部分を更新する
    qq = Bookmark.find_by(question_id: question.id)
    case flg.to_i
    when Constants.bookmark_flg.favorite then
      qq.favorite = true
    when Constants.bookmark_flg.known then
      qq.known = true
    end
    # フラグを更新する
    qq.save!
  end

  # フラグを調べてfalseにする、もし両方falseになったらテーブルからレコードを削除する
  def unbookmark(question, flg)

    qq = Bookmark.find_by(question_id: question.id)
    case flg.to_i
    when Constants.bookmark_flg.favorite then
      qq.favorite = false
    when Constants.bookmark_flg.known then
      qq.known = false
    end

    # もしフラグが両方falseになるならレコードごと削除する
    if qq.favorite == false && qq.known == false
      bookmarks_questions.destroy(question)
    else
      # 片方でもフラグが立ってるなら、レコードを更新する
      qq.save!
    end
  end
 
  # 中間テーブルを利用したモデルコレクションから、
  # 引数のQuestionオブジェクトに該当するデータがあれば、そのfavoriteフラグを調べる
  def favorite?(question)
    if(bookmarks_questions.include?(question))
      q = Bookmark.find_by(question_id: question.id)
      return q.favorite
    else
      return false
    end
  end

  # 中間テーブルを利用したモデルコレクションから、
  # 引数のQuestionオブジェクトに該当するデータがあれば、そのknownフラグを調べる
  def known?(question)
    if(bookmarks_questions.include?(question))
      q = Bookmark.find_by(question_id: question.id)
      return q.known
    else
      return false
    end
  end

  # 過去X日間の正答率をパーセントで算出する
  # input_dateが0(日間)なら、過去すべてでの正答率とする
  def correct_answer_rate(input_date = 0, test_format = Constants.test_format.all)
    # 自分の回答データを抽出する
    case test_format
    # テスト形式未指定なら
    when Constants.test_format.all
      # 全区間
      if input_date == 0
        my_res = Response.where(user_id: id).count
        my_mis = Response.where(user_id: id).where(correct: true).count
      # 日付範囲指定
      else
        range_date = Range.new((Time.now - input_date.days), Time.now)
        my_res = Response.where(user_id: id).where(created_at: range_date).count
        my_mis = Response.where(user_id: id).where(created_at: range_date).where(correct: true).count
      end
    # テスト形式が指定されているなら
    else
      # 全区間
      if input_date == 0
        my_res = Response.where(user_id: id).where(test_format: test_format).count
        my_mis = Response.where(user_id: id).where(test_format: test_format).where(correct: true).count
      # 日付範囲指定
      else
        range_date = Range.new((Time.now - input_date.days), Time.now)
        my_res = Response.where(user_id: id).where(test_format: test_format).where(created_at: range_date).count
        my_mis = Response.where(user_id: id).where(test_format: test_format).where(created_at: range_date).where(correct: true).count
      end
    end
    # 0除算回避
    return 0.00 if my_res == 0
    # パーセント算出して、小数点第3位を四捨五入
    return (my_mis.fdiv(my_res)*100).round(2)
  end

end