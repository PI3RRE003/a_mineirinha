require "test_helper"

class CozinhaControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get cozinha_show_url
    assert_response :success
  end
end
