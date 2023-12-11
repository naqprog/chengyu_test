class Setting < ApplicationRecord
  enum :letter_kind, { jiantizi: Constants.letter_kind.jiantizi, fantizi: Constants.letter_kind.fantizi }, prefix: true
  enum :test_format, { default: 0, etc: 1 }, prefix: true
  enum :test_kind, { default: 0, etc: 1 }, prefix: true

  belongs_to :user
end
