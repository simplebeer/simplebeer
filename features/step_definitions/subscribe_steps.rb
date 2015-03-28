Given(/^I have visited the subscribe page$/) do
  visit subscribe_path
end

When(/^I have selected that I need the starter kit$/) do
  choose("I’m new to this. I need the starter kit!")
end

Then(/^the pricing for the first month should display "(.*?)"$/) do |price|
  expect(page).to have_content("First Month: #{price}")
end

Then(/^the pricing for the first month should not be displayed$/) do
  expect(page).not_to have_content("First Month:")
end

When(/^I have selected that I don't need the starter kit$/) do
  choose("I’ve done this before. I just need ingredients.")
end
