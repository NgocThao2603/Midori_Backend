require "test_helper"

class Api::LessonsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_lessons_index_url
    assert_response :success
  end
end
