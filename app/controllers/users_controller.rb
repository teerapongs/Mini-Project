class UsersController < ApplicationController

  respond_to :html

  # GET /users
  def index
    @users = User.non_bot

    respond_with(@users) do |format|
      format.html
    end
  end

  # PUT /users/:id
  def update
    @user = User.find(params[:id])

    @user.update(user_attributes)

    respond_with(@user) do |format|
      format.html { render :nothing }
    end
  end

  private

  def user_attributes
    params.require(:user).permit(:send_standup_report, :admin, :disabled)
  end

end
