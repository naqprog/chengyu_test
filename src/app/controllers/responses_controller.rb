class ResponsesController < ApplicationController
  def new
    @response = Response.new
  end

  def create
    @response = Response.new(response_params)

    # セーブをするだけなので例外だけ発生させる
    @response.save!
  end

  private

  def response_params
    params.require(:response).permit(:test_format, :correct).merge(user_id: question_id)
  end
end
