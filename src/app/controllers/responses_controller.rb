class ResponsesController < ApplicationController
  before_action :set_user_responses, only: %i[index daily]

  def new
    @response = Response.new
  end

  def create
    @response = Response.new(response_params)

    # セーブをするだけなので例外だけ発生させる
    return if @response.save

    raise '回答データの保存に失敗しました'
  end

  # 一覧表示
  def index
    if params[:date]
      # 日本時間での日付の範囲を取得
      jst_start = Time.zone.parse(params[:date]).in_time_zone('Tokyo').beginning_of_day
      jst_end = jst_start.end_of_day
      # UTCに変換
      utc_start = jst_start.utc
      utc_end = jst_end.utc
      # UTCの範囲を使用してクエリを実行
      @responses = @user_responses.where(created_at: utc_start..utc_end).page(params[:page]).per(10).reverse_order
      @date_flg = true
    else
      @responses = @user_responses.page(params[:page]).per(10).reverse_order
      @date_flg = false
    end
  end

  # デイリー表示
  def daily
    res = @user_responses.map { |response| response.created_at.in_time_zone('Tokyo').to_date }
    @dates = Kaminari.paginate_array(res.uniq.reverse).page(params[:page]).per(5)
  end

  private

  # 事前にResponseデータをユーザで絞り込む
  def set_user_responses
    @user_responses = Response.where(user_id: current_user.id)
  end

  # ストロングパラメータ
  def response_params
    params.require(:response).permit(:test_format, :correct).merge(user_id: current_user.id)
  end
end
