# test/models/message_test.rb
require "test_helper"

class MessageTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123",
      username: "tester"
    )

    @message = @user.messages.new(body: "This is a secret message.")
  end

  test "is valid with default attributes" do
    assert @message.valid?
  end

  test "must belong to a user" do
    @message.user = nil
    assert_not @message.valid?
    assert_includes @message.errors[:user], "must exist"
  end

  test "body must be present" do
    @message.body = ""
    assert_not @message.valid?
    assert_includes @message.errors[:body], "can't be blank"
  end

  # Uncomment / adjust if you add a length validation like:
  # validates :body, length: { maximum: 1000 }
  #
  # test "body cannot be excessively long" do
  #   @message.body = "a" * 1001
  #   assert_not @message.valid?
  #   assert_includes @message.errors[:body], "is too long (maximum is 1000 characters)"
  # end

  test "pinned scope returns only pinned messages" do
    pinned_message   = @user.messages.create!(body: "Pinned one", pinned: true)
    unpinned_message = @user.messages.create!(body: "Not pinned", pinned: false)

    result_ids = Message.pinned.pluck(:id)

    assert_includes result_ids, pinned_message.id
    assert_not_includes result_ids, unpinned_message.id
  end

  test "public_messages scope returns only public messages" do
    public_message   = @user.messages.create!(body: "Public one", public: true)
    private_message  = @user.messages.create!(body: "Private one", public: false)

    result_ids = Message.public_messages.pluck(:id)

    assert_includes result_ids, public_message.id
    assert_not_includes result_ids, private_message.id
  end

  test "pinned and public flags can be updated" do
    @message.save!

    @message.update!(pinned: true, public: true)
    @message.reload

    assert @message.pinned?
    assert @message.public?
  end
end
