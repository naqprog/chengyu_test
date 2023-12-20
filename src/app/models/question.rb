class Question < ApplicationRecord
  enum source: {
    default: 0,
    jujuyouyisi: 1 # 成語句句有意思
  }

  has_many :synonyms, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  def chengyu_lang_setting(lang_setting)
    if(lang_setting == Constants.letter_kind.jiantizi)
      return chengyu_jianti
    else
      return chengyu_fanti
    end
  end

end
