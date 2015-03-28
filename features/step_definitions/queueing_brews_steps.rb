Given(/^I have visited the brews page$/) do
  visit brews_path
end

When(/^I see the list of (\d+) brews available$/) do |brew_count|
  expect(find(".available-brews")).to have_css(".brew", count: brew_count)
end

Then(/^the queue should show me instructions for adding brews to my queue$/) do
  expect(page).to have_css(".brew-queue .getting-started")
end

Then(/^it should display a message telling me a brew will be selected for me$/) do
  expect(page).to have_css(".brew-queue .empty-queue")
end

When(/^I select to add "(.*?)" to my queue$/) do |brew_name|
  brew_element = find(".available-brews .#{brew_name.parameterize}")
  within(brew_element) do
    click_link("Add to Queue")
  end
end

Then(/^the brew should show up at the top of the list$/) do
  expect(page).not_to have_css(".brew-queue .getting-started")
end
