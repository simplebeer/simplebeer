class ContactMessagesController < ApplicationController
  layout "home"

  def create
    @contact_message = ContactMessage.new(contact_message_params)
    authorize! :create, @contact_message

    if @contact_message.save
      redirect_to @contact_message
    else
      render :new
    end
  end

  def new
    @contact_message = ContactMessage.new
    authorize! :create, @contact_message

    @title = "Contact Us"
  end

  def show
    authorize! :create, ContactMessage
  end

private

  def contact_message_params
    params.require(:contact_message).permit(
      :email,
      :message,
      :name,
      :phone_number
    )
  end

end
