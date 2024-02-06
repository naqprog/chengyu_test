class ResponsesController < ApplicationController
  include UserResponsesSetter
  before_action :set_user_responses, only: [:index]

  def new
    @response = Response.new
  end

  def create
    @response = Response.new(response_params)

    # セーブをするだけなので、セーブ失敗したら例外を発生させる
    return if @response.save

    raise '回答データの保存に失敗しました'
  end

  # 一覧表示
  def index
    if @user_responses.empty?
      # エラーメッセージを出力する
      flash[:danger] = '回答データが存在しません'
      redirect_to profiles_path and return
    end

    @responses = filter_responses_by_date(params[:date])
    @date_flg = params[:date].present?
  end

  private

  def set_user_responses
    @user_responses = Response.where(user_id: current_user.id)
  end

  # ユーザで絞り込み済のresponseデータを更に日付データで絞り込み
  def filter_responses_by_date(date)
    if date
      # 日付指定がある場合、その日のレコードをUTCで絞り込む
      utc_range = date_in_utc(date)
      @user_responses.where(created_at: utc_range).page(params[:page]).per(10).reverse_order
    else
      # 日付指定がない場合、全レコードを表示
      @user_responses.page(params[:page]).per(10).reverse_order
    end
  end

  # 現在からdate日前までを絞り込むためのRange型データの作成
  def date_in_utc(date)
    # 日本時間での日付の範囲を取得
    jst_start = Time.zone.parse(date).in_time_zone('Tokyo').beginning_of_day
    jst_end = jst_start.end_of_day

    # UTCに変換
    utc_start = jst_start.utc
    utc_end = jst_end.utc

    # 最終データ作成
    utc_start..utc_end
  end

  # ストロングパラメータ
  def response_params
    params.require(:response).permit(:test_format, :correct).merge(user_id: current_user.id)
  end
end
