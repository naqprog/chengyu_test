class ResponsesDailyController < ApplicationController
  include UserResponsesSetter
  before_action :set_user_responses, only: [:index]

  def index
    if @user_responses.empty?
      # エラーメッセージを出力する
      flash[:danger] = '回答データが存在しません'
      redirect_to profiles_path and return
    end

    # ユーザのレスポンスデータから日別のデータを抽出し、ユニークな日付のリストを作成
    dates = @user_responses.map { |response| response.created_at.in_time_zone('Tokyo').to_date }.uniq
    # 日付リストを逆順にしてページネーションを適用
    @dates = Kaminari.paginate_array(dates.reverse).page(params[:page]).per(5)
  end
end
