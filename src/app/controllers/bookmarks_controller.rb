class BookmarksController < ApplicationController
  def create
    question = Question.find(params[:question_id])
    current_user.bookmark(question, params[:flg])
    render partial: 'exercises/favorite_button' , locals: { question: question }
  end

  def destroy
    question = current_user.bookmarks_questions.find(params[:question_id])
    current_user.unbookmark(question, params[:flg])
    render partial: 'exercises/favorite_button' , locals: { question: question }
  end
end
