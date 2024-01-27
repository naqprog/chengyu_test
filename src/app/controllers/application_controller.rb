class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    return unless params.dig(:user, :setting_attributes, :letter_kind)

    # Integer型に変換
    params[:user][:setting_attributes][:letter_kind] = params[:user][:setting_attributes][:letter_kind].to_i
    # Userと同時に使う作るSettingへの代入値をストロングパラメータとして認可
    devise_parameter_sanitizer.permit(:sign_up, keys: [setting_attributes: [:letter_kind]])
  end
end
