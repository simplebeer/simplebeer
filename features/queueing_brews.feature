Feature: Adding Brews to the Queue
  In order to receive beer
  As a new user
  I want to be able to add brews to my queue so I know
  what I'm going to receive in the upcoming months

  Scenario: I haven't queued up any brews
    Given I have visited the brews page
    When I see the list of 11 brews available
    Then the queue should show me instructions for adding brews to my queue
    And it should display a message telling me a brew will be selected for me

  @selenium
  Scenario: I add my first brew to the queue
    Given I have visited the brews page
    When I select to add "Impulse IPA" to my queue
    Then "Impulse IPA" should show up at the top of the list

  @selenium
  Scenario: I add my first brew to the queue
    Given I have visited the brews page
    When I select to add "Boardwalk Bullet Brown Ale" to my queue
    Then "Boardwalk Bullet Brown Ale" should show up at the top of the list
