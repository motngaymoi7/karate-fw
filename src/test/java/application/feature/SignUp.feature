@ignore
Feature: Sign up new user
  Background: Precondition
    * def dataGenerator = Java.type('helpers.DataGenerator')
    Given url apiUrl

  Scenario: New user signup
    * def randomEmail = dataGenerator.getRandomEmail()
    * def randomUser = dataGenerator.getRandomUsername()
    Given path 'users'
    And request
    """
    {
      "user": {
        "email": "#(randomEmail)",
        "password": "Kms@123",
        "username": "#(randomUser)"
      }
    }
    """
    When method Post
    Then status 200
    And match response ==
    """
      {
        "user": {
            "email": "#(randomEmail)",
            "username": "#(randomUser)",
            "bio": "##string",
            "image": "#string",
            "token": "#string"
        }
      }
    """
    * def userName = randomUser