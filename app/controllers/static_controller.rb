class StaticController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    @users = User.where.not(id: current_user.id)

    @total_balance = current_user.net_balance
    @you_owe = current_user.total_owed.round(2)
    @you_are_owed = current_user.total_due.round(2)

    @friends_you_owe = current_user.friends_you_owe
    @friends_who_owe_you = current_user.friends_owe_you
  end

  def person
    @users = User.where.not(id: current_user.id)
    @friend = User.find(params[:id])
    @all_expenses = current_user.shared_expenses_with(@friend)
  end
end
