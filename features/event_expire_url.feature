@time-travel
Feature: Events
  As a site user
  In order to join a hangout via the event 'show' page
  I would like to see the event link when it has been set
  And I would like to see an error message when no hangout url is set
  Pivotal Tracker: https://www.pivotaltracker.com/story/show/69250734

  Background:
    Given following events exist:
      | name         | description | category | event_date | start_time              | end_time                | repeats | time_zone |
      | ScrumWithUrl | Daily scrum | Scrum    | 2014/02/03 | 2014-02-03 01:00:00 UTC | 2014-02-03 02:00:00 UTC | never   | UTC       |

  @time-travel-step
  Scenario: Make sure the HOA link is visible when it is set
    Given the HOA link for the "ScrumWithUrl" event is set
    And I am on the show page for event "ScrumWithUrl"
    And the date is "2014/10/11 00:59:00 UTC"
    Then I should see the "HOA" link

  @time-travel-step
  Scenario: Make sure a message is displayed when HOA link in not set
    Given the HOA link for the "ScrumWithUrl" event is not set
    And I am on the show page for event "ScrumWithUrl"
    And the date is "2014/10/11 00:59:00 UTC"
    Then I should see the "hangout url unset" message

  @time-travel-step
  Scenario: Make sure the HOA link is reset after the end time
    Given I am on the show page for event "ScrumWithUrl"
    And the date is "2014/10/11 02:01:00 UTC"
    And I should see the "hangout url unset" message
