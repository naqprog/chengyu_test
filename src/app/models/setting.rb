class Setting < ApplicationRecord
  enum :letter_kind, { jiantizi: 0, fantizi: 1 }, prefix: true
  enum :test_format, { default: 0, etc: 1 }, prefix: true
  enum :test_kind, { default: 0, etc: 1 }, prefix: true

  belongs_to :user
end
