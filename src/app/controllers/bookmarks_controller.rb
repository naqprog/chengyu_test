class BookmarksController < ApplicationController
  before_action :set_bookmark_type, only: [:index]

  # 一覧表示
  def index
    if @bookmarks.empty?
      # エラーメッセージを出力する
      flash[:danger] = bookmark_type_message
      redirect_to profiles_path and return
    end

    # 問題IDでソート
    @bookmarks.order!(:question_id)

    # データが取得できたら問題データを入手
    @questions = []
    @bookmarks.each do |bk|
      @questions << Question.find(bk.question_id)
    end
    # ページネーションできる型に変換
    @questions = Kaminari.paginate_array(@questions).page(params[:page]).per(10)
  end

  # ある問題に対し、favoriteあるいはknownのフラグを付ける
  def create
    question = Question.find(params[:question_id])
    current_user.bookmark(question, params[:flg])
    handle_redirection(question)
  end

  # ある問題に対し、favoriteあるいはknownのフラグを外す
  def destroy
    question = current_user.bookmarks_questions.find(params[:question_id])
    current_user.unbookmark(question, params[:flg])
    handle_redirection(question)
  end

  private

  # ユーザがbookmarkしているデータを書き集める
  def set_bookmark_type
    @bookmarks = case params[:flg].to_i
                 when Constants.bookmark_flg.favorite
                   current_user.bookmarks.where(favorite: true)
                 when Constants.bookmark_flg.known
                   current_user.bookmarks.where(known: true)
                 else
                   raise '表示用に事前にbookmarkされているデータを収集する際、ありえないbookmark_flgの内部状況でメソッドコールが行われている'
                 end
  end

  def bookmark_type_message
    case params[:flg].to_i
    when Constants.bookmark_flg.favorite
      'お気に入りが存在しません'
    when Constants.bookmark_flg.known
      '既知リストが存在しません'
    else
      raise 'エラーメッセージを振り分ける際、ありえないbookmark_flgの内部状況でメソッドコールが行われている'
    end
  end

  def handle_redirection(question)
    # 直前にいたURLを入手
    url = Rails.application.routes.recognize_path(request.referer)
    # URLによってrenderするかredirectするかを変える
    if url[:controller] == 'questions' && url[:action] == 'show'
      render partial: 'shared/favorite_button', locals: { question: }
    elsif url[:controller] == 'exercises' && (url[:action] == 'result_chengyu' || url[:action] == 'result_mean')
      render partial: 'shared/favorite_button', locals: { question: }
    elsif (url[:controller] == 'questions' && url[:action] == 'index') ||
          (url[:controller] == 'responses' && url[:action] == 'index') ||
          (url[:controller] == 'bookmarks' && url[:action] == 'index')
      redirect_to request.referer
    end
  end
end
