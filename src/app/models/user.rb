class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { general: Constants.role.general, admin: Constants.role.admin }

  has_one :setting, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarks_questions, through: :bookmarks, source: :question

  # テーブルにオブジェクトを追加する
  def bookmark(question)
    bookmarks_questions << question
  end

  # テーブルから引数のオブジェクトに該当するレコードを削除する
  def unbookmark(question)
    bookmarks_questions.destroy(question)
  end
 
  # 中間テーブルを利用したモデルコレクションから、
  # 引数のQuestionオブジェクトに該当するデータがあるかを調べる
  def bookmark?(question)
    bookmarks_questions.include?(question)
  end
  
end
