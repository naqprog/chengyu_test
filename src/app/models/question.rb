class Question < ApplicationRecord
  enum source: {
    default: 0,
    jujuyouyisi: 1 # 成語句句有意思
  }

  has_many :synonyms, dependent: :destroy
end
