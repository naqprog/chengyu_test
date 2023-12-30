class BookmarksController < ApplicationController

  # 一覧表示
  def index
    @flg = params[:flg].to_i

    # 条件に合ったブックマークデータを取得する
    bookmark = []
    if @flg == Constants.bookmark_flg.favorite
      bookmark = Bookmark.where(user_id: current_user.id).where(favorite: true)
      if bookmark.empty?
        # エラーで返す
        flash[:danger] = "お気に入りが存在しません"
        return redirect_to profiles_path
      end
    elsif @flg == Constants.bookmark_flg.known
      bookmark = Bookmark.where(user_id: current_user.id).where(known: true)
      if bookmark.empty?
        # エラーで返す
        flash[:danger] = "既知リストが存在しません"
        return redirect_to profiles_path
      end
    end
    # 問題IDでソート
    bookmark.order!(:question_id)

    # データが取得できたら問題データを入手
    @question = []
    bookmark.each do |bk|
      @question << Question.find(bk.question_id)
    end
    # ページネーションできる型に変換
    @question = Kaminari.paginate_array(@question).page(params[:page]).per(10)

  end

  def create
    question = Question.find(params[:question_id])
    current_user.bookmark(question, params[:flg])

    # アクションがリクエストされた元を調べて、それに対応したレンダリングをリクエストする
    url = Rails.application.routes.recognize_path(request.referer)

    if (url[:controller] == "questions" && url[:action] == "show") \
      || (url[:controller] == "exercises" && url[:action] == "result_chengyu")
      render partial: 'shared/favorite_button' , locals: { question: question }
    elsif (url[:controller] == "questions" && url[:action] == "index") \
      || (url[:controller] == "responses" && url[:action] == "index") \
      || (url[:controller] == "bookmarks" && url[:action] == "index")
      redirect_to request.referer
    end
  end

  def destroy
    question = current_user.bookmarks_questions.find(params[:question_id])
    current_user.unbookmark(question, params[:flg])

    # アクションがリクエストされた元を調べて、それに対応したレンダリングをリクエストする
    url = Rails.application.routes.recognize_path(request.referer)

    if (url[:controller] == "questions" && url[:action] == "show") \
      || (url[:controller] == "exercises" && url[:action] == "result_chengyu")
      render partial: 'shared/favorite_button' , locals: { question: question }
    elsif (url[:controller] == "questions" && url[:action] == "index") \
      || (url[:controller] == "responses" && url[:action] == "index") \
      || (url[:controller] == "bookmarks" && url[:action] == "index")
      redirect_to request.referer
    end
  end
end
