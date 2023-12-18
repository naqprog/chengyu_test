class SettingsController < ApplicationController
  # ログインしているときのみ実行を許可し、していなければログイン画面を促す
  before_action :authenticate_user!

  def edit
  end

  def update
    # フォームからのパラメータを変換
    setting = current_user.setting
    convert_params

    # 設定更新
    if(setting.update(@pp))
      # 更新成功
      flash[:success] = "設定の更新に成功しました"
      redirect_to action: :edit
    else
      # 更新失敗
      flash[:danger] = "設定の更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def convert_params
    @pp = params.permit(:test_format, :test_kind, :letter_kind)
    @pp.transform_values!(&:to_i)
  end

end
