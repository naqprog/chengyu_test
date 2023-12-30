class ResponsesController < ApplicationController
  def new
    @response = Response.new
  end

  def create
    @response = Response.new(response_params)

    # セーブをするだけなので例外だけ発生させる
    @response.save!
  end

  # 一覧表示
  def index
    if params[:date]
      @responses = Response.where(user_id: current_user.id).where(created_at: params[:date].to_date.all_day).page(params[:page]).per(10).reverse_order
      @date_flg = true
    else
      @responses = Response.where(user_id: current_user.id).page(params[:page]).per(10).reverse_order
      @date_flg = false
    end
  end

  # デイリー表示
  def daily
    res = Response.where(user_id: current_user.id).map{|dates| dates.created_at.to_date}
    @dates = Kaminari.paginate_array(res.uniq.reverse).page(params[:page]).per(5)
  end

  private

  def response_params
    params.require(:response).permit(:test_format, :correct).merge(user_id: question_id)
  end
end
