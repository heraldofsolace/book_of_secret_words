class StaticPagesController < ApplicationController
  before_action :authenticate_user!, only: %i[ dashboard ]
  def home
  end

  def dashboard
    @messages = current_user.messages.order(pinned: :desc, created_at: :desc).page params[:page]
    @user = current_user
  end

  def public_profile
    @user = User.find_by(username: params[:username])
    @messages = @user.messages.public_messages.order(created_at: :desc).page params[:page]
  end
end
