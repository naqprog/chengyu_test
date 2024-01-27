class QuestionsController < ApplicationController
  # 一覧表示
  def index
    # params[:q]には検索フォームで指定した検索条件が入る
    @search_data = Question.ransack(params[:q])
    @questions = @search_data.result.page(params[:page]).per(10)
  end

  def show
    @question = Question.find(params[:id])
    @letter_kind = user_signed_in? ? Setting.letter_kinds[current_user.setting.letter_kind] : Constants.letter_kind.jiantizi
    @synonyms = Synonym.find_synonyms(@question.id)
  end

  def search
    @questions = Question.search_by_letter_kind(params[:q], current_user)
    respond_to do |format|
      format.js
    end
  end
end
