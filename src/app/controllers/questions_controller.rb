class QuestionsController < ApplicationController
  def show
    @question = Question.find(params[:id])

    if user_signed_in?
      @letter_kind = Setting.letter_kinds[current_user.setting.letter_kind]
    else
      @letter_kind = Constants.letter_kind.jiantizi # デフォルトを簡体字にする
    end

    # question_idとquestion_another_idのどちらかに@question.idが入っていたらリスト入り
    @tmp_sy = Synonym.where(question_id: @question.id).or(Synonym.where(question_another_id: @question.id))

    # 同義語データから見つけたものの逆のidを配列に格納していく
    @synonym = []
    @tmp_sy.each do |sy|
      if sy.question_id == @question.id
        @synonym << sy.question_another_id
      else
        @synonym << sy.question_id
      end
    end

  end
end
