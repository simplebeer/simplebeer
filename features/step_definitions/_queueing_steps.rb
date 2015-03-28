Given(/^I have visited the brews page$/) do
  visit brews_path
end

When(/^I select to add "(.*?)" to my queue$/) do |brew_name|
  brew_element = find(".available-brews .#{brew_name.parameterize}")
  within(brew_element) do
    click_link("Add to Queue")
  end
end
