Then(/^I should see the rejected auction as a needs attention auction$/) do
  auction = Admin::NeedsAttentionAuctionListItem.new(@auction)

  ['Title', 'Delivery Deadline', 'Delivery URL', 'Vendor Name', 'Rejected At'].each_with_index do |header, i|
    within(:xpath, th_xpath(table_id: 'table-rejected', column: i + 1)) do
      expect(page).to have_content(header)
    end
  end

  [auction.title, auction.delivery_due_at, auction.delivery_url,
   auction.winning_bidder.name, auction.rejected_at].each_with_index do |expected, i|
    within(:xpath, cel_xpath(table_id: 'table-rejected', column: i + 1)) do
      expect(page).to have_content(expected)
    end
  end
end

Then(/^I should see a table listing all Draft auctions$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that table I should see a column labeled Title$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that column I should see the title for each auction$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that table I should see a column labeled Starting Date$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that column I should see the starting date for each auction$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that table I should see a column labeled Ending Date$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that column I should see the ending date for each auction$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that table I should see a column labeled Delivery Deadline$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that column I should see the delivery deadline for each auction$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that table I should see a column labeled C(\d+) Request$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that column I should see the C(\d+) request state for each auction$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that table I should see a column labeled Action$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^in that column I should see the edit link for each auction$/) do
  pending # Write code here that turns the phrase above into concrete actions
end
