Feature: Removing Brews from the Queue
  In order to receive beer
  As a new user
  I want to be able to remove brews from my queue so I know
  what I'm going to receive in the upcoming months

  @selenium
  Scenario: I add my first brew to the queue
    Given I have visited the brews page
    When I select to add "Impulse IPA" to my queue
    When I select to remove "Impulse IPA" from my queue
    Then "Impulse IPA" should not be in the list
