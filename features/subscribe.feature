Feature: Signing up for a new subscription
  In order to sign up
  As a new user
  I want to be able to select whether I need a
  starter kit sent along with my first month's ingredients

  @selenium
  Scenario: I am a homebrew noob who needs the starter kit
    Given I have visited the subscribe page
    When I have selected that I need the starter kit
    Then the pricing for the first month should display "$100"

  @selenium
  Scenario: I already have the equipment I need to brew a gallon of beer
    Given I have visited the subscribe page
    When I have selected that I don't need the starter kit
    Then the pricing for the first month should display "$25"
