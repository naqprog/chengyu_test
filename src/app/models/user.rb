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

  # 自分が既知フラグを立てている問題数を返す
  def known_num
    return Bookmark.where(user_id: id).where(known: true).count
  end

  # 過去X日間の問題に答えた回数を返す
  # input_daysが0(日間)なら、過去すべて
  def get_answer_num(input_days = 0, test_format = Constants.test_format.all)
    # 自分の回答データを抽出する
    case test_format
    # テスト形式未指定なら
    when Constants.test_format.all
      # 全区間
      if input_days == 0
        return Response.where(user_id: id).count
      # 日付範囲指定
      else
        range_date = Range.new((Time.now - input_days.days), Time.now)
        return Response.where(user_id: id).where(created_at: range_date).count
      end
    # テスト形式が指定されているなら
    else
      # 全区間
      if input_days == 0
        return Response.where(user_id: id).where(test_format: test_format).count
      # 日付範囲指定
      else
        range_date = Range.new((Time.now - input_days.days), Time.now)
        return Response.where(user_id: id).where(test_format: test_format).where(created_at: range_date).count
      end
    end  
  end

  # 過去X日間の正答回数を返す
  # input_daysが0(日間)なら、過去すべて
  def get_correct_num(input_days = 0, test_format = Constants.test_format.all)
    # 自分の回答データを抽出する
    case test_format
    # テスト形式未指定なら
    when Constants.test_format.all
      # 全区間
      if input_days == 0
        return Response.where(user_id: id).where(correct: true).count
      # 日付範囲指定
      else
        range_date = Range.new((Time.now - input_days.days), Time.now)
        return Response.where(user_id: id).where(created_at: range_date).where(correct: true).count
      end
    # テスト形式が指定されているなら
    else
      # 全区間
      if input_days == 0
        return Response.where(user_id: id).where(test_format: test_format).where(correct: true).count
      # 日付範囲指定
      else
        range_date = Range.new((Time.now - input_days.days), Time.now)
        return Response.where(user_id: id).where(test_format: test_format).where(created_at: range_date).where(correct: true).count
      end
    end
  end

  # 過去X日間の正答率をパーセントで算出し、回答回数と正答回数をまとめて返す
  # input_daysが0(日間)なら、過去すべて
  def get_correct_answer_rate_data(input_days = 0, test_format = Constants.test_format.all)
    # 回答回数と正答回数を取得
    my_res = get_answer_num(input_days, test_format)
    my_cor = get_correct_num(input_days, test_format)
    # 0除算回避
    return 0.00 if my_res == 0
    # パーセント算出して、小数点第3位を四捨五入
    return my_res, my_cor, (my_cor.fdiv(my_res)*100).round(2)
  end

  # 日付を入力して、その日の正答率をパーセントで算出し、回答回数と正答回数をまとめて返す
  def get_daily_correct_answer_rate_data(input_date, test_format = Constants.test_format.all)
    # 自分の回答データを抽出する
    case test_format
      # テスト形式未指定なら
    when Constants.test_format.all
      binding.break
      my_res = Response.where(user_id: id).where(created_at: input_date.all_day).count
      my_cor = Response.where(user_id: id).where(created_at: input_date.all_day).where(correct: true).count
    # テスト形式が指定されているなら
    else
      my_res = Response.where(user_id: id).where(test_format: test_format).where(created_at: input_date.all_day).count
      my_cor = Response.where(user_id: id).where(test_format: test_format).where(created_at: input_date.all_day).where(correct: true).count
    end

    # 0除算回避
    return 0.00 if my_res == 0
    # パーセント算出して、小数点第3位を四捨五入
    return my_res, my_cor, (my_cor.fdiv(my_res)*100).round(2)
  end

end