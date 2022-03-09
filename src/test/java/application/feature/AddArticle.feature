Feature: Add Article

  Background: Define URL
    * def dataGenerator = Java.type('helpers.DataGenerator')
    Given url apiUrl

  Scenario: Create a new article
    * def randomArticleName = dataGenerator.getRandomArticleName()
    Given path 'articles'
    And request {"article": {"tagList": [],"title": "#(randomArticleName)","description": "des","body": "body"}}
    When method Post
    Then status 200
    And match response.article.title == "#(randomArticleName)"
    * def responseArticle = response.article