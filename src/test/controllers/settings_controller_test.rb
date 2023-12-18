require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get settings_edit_url
    assert_response :success
  end
end
