class Response < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :question

  enum :test_format, { chengyu: 0, mean: 1 }
end
