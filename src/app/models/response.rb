class Response < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :question
end
