class Question < ApplicationRecord
  enum source: {
    default: 0,
    jujuyouyisi: 1 # 成語句句有意思
  }

  has_many :synonyms, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  # ransack用
  def self.ransackable_attributes(_auth_object = nil)
    %w[chengyu_fanti chengyu_jianti created_at id level mean note other_answer_fanti other_answer_jianti
       other_answer_pinyin pinyin source updated_at]
  end

  # 言語設定に合わせてクエリの適用先を変更する
  def self.search_by_letter_kind(query, user)
    if user&.setting&.letter_kind == Constants.letter_kind.fantizi
      where('chengyu_fanti LIKE ?', "%#{query}%")
    else
      where('chengyu_jianti LIKE ?', "%#{query}%")
    end
  end

  def chengyu_lang_setting(lang_setting)
    if lang_setting == Constants.letter_kind.jiantizi
      chengyu_jianti
    else
      chengyu_fanti
    end
  end

  def other_answer_lang_setting(lang_setting)
    if lang_setting == Constants.letter_kind.jiantizi
      other_answer_jianti
    else
      other_answer_fanti
    end
  end
end
