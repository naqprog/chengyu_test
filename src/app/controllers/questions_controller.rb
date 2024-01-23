class QuestionsController < ApplicationController

  # 一覧表示
  def index
    # params[:q]には検索フォームで指定した検索条件が入る
    @search_data = Question.ransack(params[:q])
    @question = @search_data.result.page(params[:page]).per(10)

    @question_all = Question.all
  end

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

  def search
    if user_signed_in? && Setting.letter_kinds[current_user.setting.letter_kind] == Constants.letter_kind.fantizi
      @questions = Question.where("chengyu_fanti like ?", "%#{params[:q]}%")
    else
      @questions = Question.where("chengyu_jianti like ?", "%#{params[:q]}%")
    end
    respond_to do |format|
      format.js
    end
  end

end
