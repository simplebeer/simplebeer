require "rails_helper"

describe LineItem, "#total" do

  context "with a multiplier" do

    it "returns the correct total" do
      invoice = create(:multiplied_line_item)

      expected_total = invoice.amount * invoice.quantity
      expect(invoice.total).to eq(expected_total)
    end
  end

  context "with no multiplier" do

    it "returns the correct total" do
      invoice = create(:single_line_item)

      expect(invoice.total).to eq(invoice.amount)
    end

  end

end
