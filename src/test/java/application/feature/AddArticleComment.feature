Feature: Add Article



  Background: Define URL
    Given url apiUrl

  Scenario: Create a new article

    Given path 'articles/' + slugId + '/comments'
    And request {"comment": {"body": "body body"}}
    When method Post
    Then status 200
    And match response.comment.body == "body body"
    And def commentId = response.comment.id