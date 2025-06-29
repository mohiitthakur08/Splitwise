class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_friends, only: [:show, :edit, :update]

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: 'Profile updated successfully.'
    else
      render :edit
    end
  end

  private

  def set_user
    @user = current_user
  end

  def set_friends
    @users = User.where.not(id: @user.id)
  end

  def user_params
    params.require(:user).permit(:name, :email, :mobile_number)
  end
end
