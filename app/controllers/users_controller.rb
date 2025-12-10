class UsersController < ApplicationController
  def check_username
    username = params[:username].to_s.strip

    available =
      username.present? &&
      username.match?(/\A[a-zA-Z0-9._]+\z/) &&
      username.length.between?(3, 20) &&
      !User.where("LOWER(username) = ?", username.downcase).exists?

    render json: { available: available }
  end
end
