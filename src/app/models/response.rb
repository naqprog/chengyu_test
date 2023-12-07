class Response < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :question

  enum :test_format, { default: 0, etc: 1 }
end
