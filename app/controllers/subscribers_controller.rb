class SubscribersController < ApplicationController
  layout "account"

  def edit
    @user = current_user
    @title = "Account ~ #{current_user.display_name}"
  end

  def show
    redirect_to edit_user_path
  end

  def update
    @user = current_user
    @title = "Account ~ #{current_user.display_name}"

    if user_params.has_key?(:password)
      if @user.update_with_password(user_params)
        sign_in(@user, bypass: true)
        redirect_to edit_user_path, notice: "Password updated successfully."
      else
        render :edit
      end
    else
      if @user.update_without_password(user_params)
        redirect_to edit_user_path, notice: "Account updated successfully."
      else
        render :edit
      end
    end
  end

private

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
