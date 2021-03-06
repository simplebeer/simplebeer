class UsersController < ApplicationController
  before_action :set_user

  def edit
    authorize! :update, @user
    @title = "My Account"
  end

  def show
    authorize! :read, @user
    redirect_to edit_user_path(@user)
  end

  def update
    authorize! :update, @user

    @title = "My Account"

    if user_params.has_key?(:password)
      if @user.update_with_password(user_params)
        sign_in(@user, bypass: true)
        redirect_to edit_user_path(@user), notice: "Password updated successfully."
      else
        render :edit
      end
    else
      if @user.update_without_password(user_params)
        redirect_to edit_user_path(@user), notice: "Account updated successfully."
      else
        render :edit
      end
    end
  end

private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :current_password,
      :email,
      :name,
      :password,
      :password_confirmation
    )
  end

end
