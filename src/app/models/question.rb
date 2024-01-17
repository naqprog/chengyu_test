class Question < ApplicationRecord
  enum source: {
    default: 0,
    jujuyouyisi: 1 # 成語句句有意思
  }

  has_many :synonyms, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  # ransack用
  def self.ransackable_attributes(auth_object = nil)
    ["chengyu_fanti", "chengyu_jianti", "created_at", "id", "level", "mean", "note", "other_answer_fanti", "other_answer_jianti", "other_answer_pinyin", "pinyin", "source", "updated_at"]
  end

  def chengyu_lang_setting(lang_setting)
    if(lang_setting == Constants.letter_kind.jiantizi)
      return chengyu_jianti
    else
      return chengyu_fanti
    end
  end

  def other_answer_lang_setting(lang_setting)
    if(lang_setting == Constants.letter_kind.jiantizi)
      return other_answer_jianti
    else
      return other_answer_fanti
    end
  end

end
