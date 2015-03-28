Given(/^I have visited the home page$/) do
  visit root_path
end

When(/^I have selected that I need the starter kit$/) do
  choose("I'm a noob. I need the starter kit.")
end

Then(/^the pricing for the first month should display "(.*?)"$/) do |price|
  expect(page).to have_content("First Month: #{price}")
end

When(/^I have selected that I don't need the starter kit$/) do
  choose("I've done this before. I just need ingredients.")
end
