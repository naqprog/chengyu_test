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
    @responses = Response.where(user_id: current_user.id).page(params[:page]).per(10).reverse_order
  end

  private

  def response_params
    params.require(:response).permit(:test_format, :correct).merge(user_id: question_id)
  end
end
