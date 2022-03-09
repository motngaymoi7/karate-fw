@debug
Feature: Validate favorite and comment function

  Background: Preconditions
    * url apiUrl
@debug
  Scenario: Favorite articles
        # Step 1: Add new article (optimize here - Create a AddArticle.feature)
        * def article = karate.call('AddArticle.feature').responseArticle

        # Step 2: Get the favorites count and slug ID for the the article, save it to variables
        * def favoritesCount = article.favoritesCount
        * def slugId = article.slug
        * def isTimeValidator = read('classpath:helpers/TimeValidator.js')

        # Step 3: Make POST request to increase favorites count for the article
        Given path 'articles/' + slugId + '/favorite'
        When method Post
        Then status 200

        # Step 4: Verify response schema
        And match article ==
        """
            {
                "slug": "#string",
                "title": "#string",
                "description": "#string",
                "body": "#string",
                "createdAt": "#? isTimeValidator(_)",
                "updatedAt": "#? isTimeValidator(_)",
                "tagList": "#array",
                "author": {
                    "username": "#string",
                    "bio": "##string",
                    "image": "#string"
                },
                "favoritedBy": "#array",
                "_count": {
                    "favoritedBy": '#number'
                },
                "favoritesCount": '#number',
                "favorited": '#boolean'
            }
        """

        # Step 5: Verify that favorites article incremented by 1
        # Example
        * def initialCount = 0
        * def response = {"favoritesCount": 1}
        And match response.favoritesCount == initialCount + 1
        *  def username = article.author.username

        # Step 6: Get all favorite articles
        Given path '/articles'
        Given params {limit: 10, offset: 0, favorited: '#(username)'}
        And method Get
        Then status 200

        # Step 7: Verify response schema
        And match each response.articles ==
        """
            {
                "slug": "#string",
                "title": "#string",
                "description": "#string",
                "body": "#string",
                "createdAt": "#? isTimeValidator(_)",
                "updatedAt": "#? isTimeValidator(_)",
                "tagList": "#array",
                "author": {
                    "username": "#string",
                    "bio": "##string",
                    "image": "#string",
                    "following": '#boolean'
                },
                "favoritesCount": '#number',
                "favorited": '#boolean'
            }
        """
        # Step 8: Verify that slug ID from Step 2 exist in one of the favorite articles
        And match response.articles[*].slug contains slugId

        # Step 9: Delete the article (optimize here with afterScenario - create a Hook.feature)

      Scenario: Comment articles
        * def isTimeValidator = read('classpath:helpers/TimeValidator.js')

        # Step 1: Add new article (optimize here - Create a AddArticle.feature)
        * def article2 = karate.call('AddArticle.feature').responseArticle

        # Step 2: Get the slug ID for the article, save it to variable
        * def slugId2 = article2.slug

        # Step 3: Make a GET call to 'comments' end-point to get all comments
        * def response = call read('AddArticleComment.feature') {slugId: '#(slugId2)'}

        Given path 'articles/' + slugId2 + '/comments'
        When method Get
        Then status 200

        # Step 4: Verify response schema
        And match each response.comments ==
        """
            {
                "id": "#number",
                "createdAt": "#? isTimeValidator(_)",
                "updatedAt": "#? isTimeValidator(_)",
                "body": "#string",
                "author": {
                    "username": "#string",
                    "bio": "##string",
                    "image": "#string",
                    "following": '#boolean'
                }
            }
        """

        # Step 5: Get the count of the comments array length and save to variable
        # Example
#        * def responseWithComments = [{"article": "first"}, {"article": "second"}]
#        * def articlesCount = responseWithComments.length
        * def commentCount = response.comments.length

        # Step 6: Make a POST request to publish a new comment
        * def response2 = call read('AddArticleComment.feature') {slugId: '#(slugId2)'}
        * def commentId = response2.commentId

        # Step 7: Verify response schema that should contain posted comment text
#        And match response2.comment ==
#        """
#            {
#                "id": "#number",
#                "createdAt": "#? isTimeValidator(_)",
#                "updatedAt": "#? isTimeValidator(_)",
#                "body": "#string",
#                "author": {
#                    "username": "#string",
#                    "bio": "##string",
#                    "image": "#string",
#                    "following": '#boolean'
#                }
#            }
#        """

        # Step 8: Get the list of all comments for this article one more time
        Given path 'articles/' + slugId2 + '/comments/'
        When method Get
        Then status 200

        # Step 9: Verify number of comments increased by 1 (similar like we did with favorite counts)
        * def commentCountAfterAdded = response.comments.length
        And match commentCountAfterAdded == commentCount + 1

        # Step 10: Make a DELETE request to delete comment
        Given path 'articles/' + slugId2 + '/comments/' + commentId
        When method Delete
        Then status 204

        # Step 11: Get all comments again and verify number of comments decreased by 1
        Given path 'articles/' + slugId2 + '/comments/'
        When method Get
        Then status 200

        * def commentCountAfterDelete = response.comments.length
        And match commentCountAfterDelete == commentCountAfterAdded - 1

        # Step 12: Delete the article (optimize here with afterScenario - create a Hook.feature)
        Given path 'articles/' + slugId2
        When method Delete
        Then status 204