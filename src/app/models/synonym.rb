class Synonym < ApplicationRecord
  belongs_to :question

  # クラスメソッド
  # 同義語チェック trueで判定OK(見つからなかった)
  def self.same_check(id_1, id_2)
    # synonymを全検索
    tmp = Synonym.where(question_id: id_1).where(question_another_id: id_2)
    # tmpがnilじゃない＝見つかったらならNG
    return false if tmp.present?
    # synonymをidを入れ替えて全検索
    tmp = Synonym.where(question_id: id_2).where(question_another_id: id_1)
    # tmpがnilならOKなのだから
    return false if tmp.present?
    # ここまで来たら大丈夫
    return true
  end

end
