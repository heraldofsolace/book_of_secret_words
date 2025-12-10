class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]
  before_action :set_user, only: %i[ new create ]
  # GET /messages or /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1 or /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    if @user.nil?
      redirect_to root_path, notice: "User not found."
      return
    end
    @message = @user.messages.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages or /messages.json
  def create
    respond_to do |format|
      if @user.nil?
        format.html { redirect_to root_path, notice: "User not found." }
        format.json { render json: { error: "User not found" }, status: :not_found }
      else
        @message = @user.messages.new(message_params)
        if @message.save
          MessageMailer.new_message_notification(@user, @message).deliver_later
          format.html { redirect_to root_path, notice: "Message was successfully created." }
          format.json { render :show, status: :created, location: @message }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @message.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.user != current_user
        Rails.logger.info "User attempted to edit a message they did not own."
        format.html { redirect_to dashboard_path, notice: "You are not allowed to edit this message." }
        format.json { render json: { error: "You are not allowed to edit this message." }, status: :forbidden }
      else
        if @message.update(update_message_params)
          format.html { redirect_to @message, notice: "Message was successfully updated.", status: :see_other }
          format.json { render :show, status: :ok, location: @message }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @message.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    respond_to do |format|
      if @message.user != current_user
        format.html { redirect_to dashboard_path, notice: "You are not allowed to delete this message." }
        format.json { render json: { error: "You are not allowed to delete this message." }, status: :forbidden }
      else
        @message.destroy!

        format.html { redirect_to dashboard_path, notice: "Message was successfully destroyed.", status: :see_other }
        format.json { head :no_content }
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params.expect(:id))
    end

    def set_user
      @user = User.find_by(username: params.expect(:username))
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.expect(message: [ :body ])
    end

  def update_message_params
    params.expect(message: [ :pinned, :public ])
  end
end
