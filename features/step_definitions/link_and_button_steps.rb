When(/^I click on the link to the bids$/) do
  bid = WinningBid.new(@auction).find
  bid_amount = Currency.new(bid.amount).to_s
  click_on(bid_amount)
end

When(/^I click on the "Edit" link for the auction$/) do
  within('.auction-title') do
    first(:link_or_button, "Edit").click
  end
end

When(/^I click on the "?([^"]+)"? button$/) do |button|
  first(:link_or_button, button).click
end

When(/^I click on the "([^"]+)" link$/) do |label|
  first(:link, label).click
end

When(/^I click on the auction's title$/) do
  click_on(@auction.title)
end

When(/^I click on the name of the first user$/) do
  @user = User.last
  click_on(@user.name)
end

Then(/^I should see an? "([^"]+)" link$/) do |link|
  expect(page).to have_selector(:link, link)
end

Then(/^I should see the "Edit" link for the auction$/) do
  within('.auction-title') do
    expect(page).to have_selector(:link, "Edit")
  end
end

Then(/^I should not see an "Edit" link for the auction$/) do
  within('.auction-title') do
    expect(page).not_to have_selector(:link, "Edit")
  end
end

Then(/^I should not see an? "([^"]+)" link$/) do |link|
  expect(page).to_not have_selector(:link, link)
end

Then(/^I should see an? "([^"]+)" button$/) do |button|
  expect(page).to have_selector(:link_or_button, button, exact: true)
end

Then(/^I should not see an? "([^"]*)" button$/) do |button|
  expect(page).to_not have_selector(:link_or_button, button, exact: true)
end
