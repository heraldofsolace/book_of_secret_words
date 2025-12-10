# test/controllers/users_controller_test.rb
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @existing_user = User.create!(
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123",
      username: "aniket"
    )
    @existing_user.confirm if @existing_user.respond_to?(:confirm)
  end

  def json_body
    JSON.parse(@response.body)
  end

  test "returns false when username is blank" do
    get "/check_username", params: { username: "" }, as: :json

    assert_response :success
    assert_equal false, json_body["available"]
  end

  test "returns false when username has invalid characters" do
    get "/check_username", params: { username: "bad-name!" }, as: :json

    assert_response :success
    assert_equal false, json_body["available"]
  end

  test "returns false when username is too short" do
    get "/check_username", params: { username: "ab" }, as: :json

    assert_response :success
    assert_equal false, json_body["available"]
  end

  test "returns false when username is too long" do
    get "/check_username", params: { username: "a" * 21 }, as: :json

    assert_response :success
    assert_equal false, json_body["available"]
  end

  test "returns true when username is syntactically valid and not taken" do
    get "/check_username", params: { username: "new_user.01" }, as: :json

    assert_response :success
    assert_equal true, json_body["available"]
  end

  test "returns false when username is already taken (case-insensitive)" do
    # existing username is "aniket"
    get "/check_username", params: { username: "AnIkEt" }, as: :json

    assert_response :success
    assert_equal false, json_body["available"]
  end

  test "strips whitespace before checking" do
    # existing username is "aniket"
    get "/check_username", params: { username: "  aniket  " }, as: :json

    assert_response :success
    assert_equal false, json_body["available"]
  end
end
