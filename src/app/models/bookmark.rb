class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :question

  validates :user_id, uniqueness: { scope: :question_id }

  # known が true であるブックマークを返すスコープ
  scope :known, -> { where(known: true) }
end
