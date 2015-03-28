When(/^I see the list of (\d+) brews available$/) do |brew_count|
  expect(find(".available-brews")).to have_css(".brew", count: brew_count)
end

Then(/^the queue should show me instructions for adding brews to my queue$/) do
  expect(page).to have_css(".brew-queue .getting-started")
end

Then(/^it should display a message telling me a brew will be selected for me$/) do
  expect(page).to have_css(".brew-queue .empty-queue")
end

Then(/^"(.*?)" should show up at the top of the list$/) do |brew_name|
  expect(page).not_to have_css(".brew-queue .getting-started")
  expect(page).to have_css(".brew-queue .#{brew_name.parameterize}")
end
