# response_XXX_controllerで共通で使うためモジュール化
module UserResponsesSetter
  extend ActiveSupport::Concern

  private

  # 事前にResponseデータをユーザで絞り込む
  def set_user_responses
    @user_responses = Response.where(user_id: current_user.id)
  end
end
