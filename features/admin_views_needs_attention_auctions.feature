Feature: Admin view needs attention auctions
  As an admin
  I want to see the needs attention auctions dashboard
  So I can tell which auctions need my attention

  Background:
    Given I am an administrator
    And I sign in

  Scenario: Navigating to the needs attention auctions dashboard
    Given I visit the auctions section of the admin panel
    When I click on the "Needs Attention" link
    Then I should be on the Needs Attention page

  Scenario: Admin sees data for draft auctions on the Needs Attention page
    Given there is an unpublished auction
    And I visit the Needs Attention page
    Then I should see a section labeled "Drafts"
    And I should see a table listing all Draft auctions

    And in that table I should see a column labeled Title
    And in that column I should see the title for each auction

    And in that table I should see a column labeled Starting Date
    And in that column I should see the starting date for each auction

    And in that table I should see a column labeled Ending Date
    And in that column I should see the ending date for each auction

    And in that table I should see a column labeled Delivery Deadline
    And in that column I should see the delivery deadline for each auction

    And in that table I should see a column labeled C2 Request
    And in that column I should see the C2 request state for each auction

    And in that table I should see a column labeled Action
    And in that column I should see the edit link for each auction

  Scenario: Viewing the needs attention auctions dashboard
    Given there is a complete and successful auction
    And there is also an unpublished auction
    When I visit the admin needs attention auctions page
    Then I should see the name of the auction
    And I should see the edit link for the auction

  Scenario: Viewing the drafts dashboard
    Given there is an unpublished auction
    When I visit the admin drafts page
    Then I should see the auction's title

  Scenario: Viewing rejected auction
    Given there is a rejected auction
    When I visit the admin needs attention auctions page
    Then I should see the rejected auction as a needs attention auction

  Scenario: Viewing rejected auction with no bids
    Given there is a rejected auction with no bids
    When I visit the admin needs attention auctions page
    Then I should see the rejected auction as a needs attention auction
