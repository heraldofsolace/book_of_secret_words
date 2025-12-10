# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123",
      username: "aniket"
    )
  end

  test "is valid with default attributes" do
    assert @user.valid?
  end

  test "username must be present" do
    @user.username = ""
    assert_not @user.valid?
    assert_includes @user.errors[:username], "can't be blank"
  end

  test "username length must be between 3 and 20 characters" do
    @user.username = "ab"
    assert_not @user.valid?

    @user.username = "a" * 21
    assert_not @user.valid?

    @user.username = "abc"
    assert @user.valid?

    @user.username = "a" * 20
    assert @user.valid?
  end

  test "allows valid username characters" do
    valid_usernames = %w[
      aniket
      ani.ket
      ani_ket
      user01
      user.name_01
    ]

    valid_usernames.each do |name|
      @user.username = name
      assert @user.valid?, "expected #{name.inspect} to be valid"
    end
  end

  test "rejects invalid username characters" do
    invalid_usernames = [
      "ani-ket",
      " spaced",
      "space d",
      "weird!"
    ]

    invalid_usernames.each do |name|
      @user.username = name
      assert_not @user.valid?, "expected #{name.inspect} to be invalid"
      assert @user.errors[:username].present?
    end
  end

  test "username must be unique case-insensitively" do
    User.create!(
      email: "other@example.com",
      password: "password123",
      password_confirmation: "password123",
      username: "aniket"
    )

    dup = User.new(
      email: "another@example.com",
      password: "password123",
      password_confirmation: "password123",
      username: "Aniket" # different case
    )

    assert_not dup.valid?
    assert_includes dup.errors[:username], "has already been taken"
  end

  test "username cannot look like an email address" do
    @user.username = "user@example.com"
    assert_not @user.valid?
    assert_includes @user.errors[:username], "cannot be an email address"
  end

  test "destroying user destroys associated messages" do
    user = User.create!(
      email: "owner@example.com",
      password: "password123",
      password_confirmation: "password123",
      username: "owneruser"
    )

    user.messages.create!(body: "hello")
    user.messages.create!(body: "world")

    assert_difference "Message.count", -2 do
      user.destroy
    end
  end
end
