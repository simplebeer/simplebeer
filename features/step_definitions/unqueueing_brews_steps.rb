When(/^I select to remove "(.*?)" from my queue$/) do |brew_name|
  brew_element = find(".brew-queue .#{brew_name.parameterize}")
  within(brew_element) do
    click_link("Remove from Queue")
  end
end

Then(/^Then "(.*?)" should not be in the list$/) do |brew_name|
  expect(page).to have_css(".brew-queue .#{brew_name.parameterize}")
end
