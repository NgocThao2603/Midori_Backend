require "test_helper"

class Api::ChaptersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_chapters_index_url
    assert_response :success
  end
end
