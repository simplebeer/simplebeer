require "rails_helper"

describe Invoice, "#finalize!" do

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

    @subscription = create(:subscription, payment_method: create(:stripe_card))
    @subscriber = @subscription.subscriber

    @invoice = @subscriber.current_invoice
    create(:single_line_item, invoice: @invoice)
    @invoice.reload
  end

  it "should create a charge on the invoice" do
    stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
      body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge.json"))
    )
    expect(@invoice.charges.count).to eq(0)

    @invoice.finalize!

    expect(@invoice.charges.count).to eq(1)
  end

  it "should return true if the attempted charge is successful" do
    stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
      body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge.json"))
    )

    expect(@invoice.finalize!).to eq(true)
  end

  it "should return false if the attempted charge fails" do
    stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
      body:   File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge_fail.json")),
      status: 402
    )

    expect(@invoice.finalize!).to eq(false)
  end

  context "if the subscriber has enough credit on their account to cover the invoice amount" do

    before(:each) do
      @subscription = create(:subscription, payment_method: create(:stripe_card))
      @subscriber = @subscription.subscriber
      @subscriber.update_attribute(:account_balance_cents, -10000) # $100.00
      @invoice = @subscriber.current_invoice
      create(:single_line_item, invoice: @invoice, amount: Money.new(2000, "USD")) # $20.00
      @invoice.reload
    end

    it "the invoice total should be $0.00" do
      @invoice.finalize!
      expect(@invoice.total).to eq(0)
    end

    it "should update the subscriber's account balance" do
      expect(@subscriber.account_balance).to eq(Money.new(-10000, "USD")) # $100.00

      @invoice.finalize!
      @subscriber.reload

      expect(@subscriber.account_balance).to eq(Money.new(-8000, "USD")) # $80.00
    end
  end

  context "if the subscriber has credit on their account, but not the full total" do

    before(:each) do
      @subscription = create(:subscription, payment_method: create(:stripe_card))
      @subscriber = @subscription.subscriber
      @subscriber.update_attribute(:account_balance_cents, -500) # $5.00
      @invoice = @subscriber.current_invoice
      create(:single_line_item, invoice: @invoice, amount: Money.new(2000, "USD")) # $20.00
      @invoice.reload
    end

    it "the invoice total should be the total - the subscriber credit" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge.json"))
      )

      @invoice.finalize!
      expect(@invoice.total).to eq(Money.new(1500, "USD")) # $15.00
    end

    it "should update the subscriber's account balance" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge.json"))
      )

      expect(@subscriber.account_balance).to eq(Money.new(-500, "USD")) # $100.00

      @invoice.finalize!
      @subscriber.reload

      expect(@subscriber.account_balance).to eq(0)
    end

  end

end

describe Invoice, "#paid_at" do

  before(:each) do
    @invoice = create(:invoice)

  end

  context "if there is more than one successful charge" do

    it "should return the date of the first successful charge" do
      successful_charge = create(:successful_charge)
      @invoice.charges << successful_charge
      @invoice.charges << create(:successful_charge)
      @invoice.paid = true

      expect(@invoice.paid_at).to be_within(100).of(successful_charge.created_at)
    end

  end

  context "if there is no successful charge" do

    it "should return nil" do
      @invoice.charges << create(:unsuccessful_charge)
      @invoice.charges << create(:unsuccessful_charge)

      expect(@invoice.paid_at).to eq(nil)
    end

  end

end

describe Invoice, "#calculate_total" do

  before(:each) do
    @invoice = create(:invoice)
    @subscriber = @invoice.subscriber

    @single_line_item = create(:single_line_item, invoice: @invoice)
    @multiplied_line_item = create(:multiplied_line_item, invoice: @invoice)

    @invoice.reload
  end

  it "should set the total to the total of all of its line_items" do
    @invoice.send(:calculate_total)
    expected_total = @single_line_item.total + @multiplied_line_item.total

    expect(@invoice.total).to eq(expected_total)
  end

end
