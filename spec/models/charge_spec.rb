require "rails_helper"

describe Charge, "#attempt_payment" do

  before(:each) do
    stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
      body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
    )
    stub_request(:get, "https://api.stripe.com/v1/customers/cus_4paKHGMWyPEkmv").to_return(
      body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
    )
    stub_request(:get, "https://api.stripe.com/v1/customers/cus_4paKHGMWyPEkmv/cards/card123").to_return(
      body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card.json"))
    )

    @invoice = create(:invoice)
    @single_line_item = create(:single_line_item, invoice: @invoice)
    @charge = build(:charge, invoice: @invoice, payment_method: create(:stripe_card))
  end

  it "sets the status to :succeeded if payment is successful" do
    stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
      body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge.json"))
    )

    @charge.save
    expect(@charge.succeeded?).to eq(true)
  end

  it "sets the status to :failed if payment is successful" do
    stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
      body:   File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge_fail.json")),
      status: 402
    )

    @charge.save
    expect(@charge.failed?).to eq(true)
  end

end
