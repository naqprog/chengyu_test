class Setting < ApplicationRecord
  enum :letter_kind, { jiantizi: Constants.letter_kind.jiantizi, fantizi: Constants.letter_kind.fantizi }, prefix: true
  enum :test_format, { chengyu: 0, mean: 1 }, prefix: true
  enum :test_kind, { default: 0, mistake: 1, favorite: 2, rate_low: 3 }, prefix: true

  belongs_to :user
end
