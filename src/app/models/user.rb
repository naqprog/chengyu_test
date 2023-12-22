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
  
end
