# test/controllers/messages_controller_test.rb
require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  def setup
    @user = User.create!(
      email: "owner@example.com",
      password: "password123",
      password_confirmation: "password123",
      username: "owneruser"
    )

    @other_user = User.create!(
      email: "other@example.com",
      password: "password123",
      password_confirmation: "password123",
      username: "otheruser"
    )

    @message = @user.messages.create!(body: "Existing message")

    # In case Devise confirmable is enabled and you require confirmed users
    @user.confirm if @user.respond_to?(:confirm)
    @other_user.confirm if @other_user.respond_to?(:confirm)
  end

  # --- NEW / CREATE --------------------------------------------------------

  test "GET new shows form when user exists" do
    get new_user_message_path(@user.username)
    assert_response :success
    assert_select "form"
  end

  test "GET new redirects to root when user not found" do
    get new_user_message_path("unknown_user")
    assert_redirected_to root_path
    follow_redirect!
    assert_match "User not found.", @response.body
  end

  test "POST create creates message and enqueues email" do
    assert_enqueued_emails 1 do
      post user_message_path(@user.username), params: {
        message: { body: "Hello from the test." }
      }
    end

    assert_redirected_to root_path
    assert_equal "Message was successfully created.", flash[:notice]

    message = @user.messages.order(:created_at).last
    assert_equal "Hello from the test.", message.body
  end

  test "POST create does not create or enqueue when invalid" do
    assert_no_enqueued_emails do
      post user_message_path(@user.username), params: {
        message: { body: "" } # invalid
      }
    end

    assert_response :unprocessable_entity
  end

  test "POST create returns not_found JSON when user missing" do
    assert_no_enqueued_emails do
      post user_message_path("missing_user"), params: {
        message: { body: "Hi" }
      }, as: :json
    end

    assert_response :not_found
    body = JSON.parse(@response.body)
    assert_equal "User not found", body["error"]
  end

  # --- UPDATE --------------------------------------------------------------

  test "PATCH update allows owner to update pinned/public flags" do
    sign_in @user

    patch message_path(@message), params: {
      message: { pinned: true, public: true }
    }

    assert_redirected_to @message
    assert_equal "Message was successfully updated.", flash[:notice]

    @message.reload
    assert @message.pinned?
    assert @message.public?
  end

  test "PATCH update redirects non-owner with notice" do
    sign_in @other_user

    patch message_path(@message), params: {
      message: { pinned: true }
    }

    assert_redirected_to dashboard_path
    assert_equal "You are not allowed to edit this message.", flash[:notice]

    @message.reload
    refute @message.pinned?
  end

  test "PATCH update returns forbidden JSON for non-owner" do
    sign_in @other_user

    patch message_path(@message), params: {
      message: { pinned: true }
    }, as: :json

    assert_response :forbidden
    body = JSON.parse(@response.body)
    assert_equal "You are not allowed to edit this message.", body["error"]

    @message.reload
    refute @message.pinned?
  end

  # --- DESTROY -------------------------------------------------------------

  test "DELETE destroy allows owner to delete message" do
    sign_in @user

    assert_difference "Message.count", -1 do
      delete message_path(@message)
    end

    assert_redirected_to dashboard_path
    assert_equal "Message was successfully destroyed.", flash[:notice]
  end

  test "DELETE destroy prevents non-owner from deleting message" do
    sign_in @other_user

    assert_no_difference "Message.count" do
      delete message_path(@message)
    end

    assert_redirected_to dashboard_path
    assert_equal "You are not allowed to delete this message.", flash[:notice]
  end

  test "DELETE destroy returns forbidden JSON for non-owner" do
    sign_in @other_user

    assert_no_difference "Message.count" do
      delete message_path(@message), as: :json
    end

    assert_response :forbidden
    body = JSON.parse(@response.body)
    assert_equal "You are not allowed to delete this message.", body["error"]
  end
end
