class Synonym < ApplicationRecord
  belongs_to :question

  # クラスメソッド
  # 同義語チェック trueで判定OK(見つからなかった)
  def self.same_check(id_a, id_b)
    # synonymを全検索
    tmp = Synonym.where(question_id: id_a).where(question_another_id: id_b)
    # tmpがnilじゃない＝見つかったらならNG
    return false if tmp.present?

    # synonymをidを入れ替えて全検索
    tmp = Synonym.where(question_id: id_b).where(question_another_id: id_a)
    # tmpがnilならOKなのだから
    return false if tmp.present?

    # ここまで来たら大丈夫
    true
  end

  def self.find_synonyms(question_id)
    synonyms = where(question_id:).or(where(question_another_id: question_id))
    synonyms.map { |sy| sy.question_id == question_id ? sy.question_another_id : sy.question_id }
  end
end
