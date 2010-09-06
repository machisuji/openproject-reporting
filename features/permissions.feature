Feature: Permissions

  Scenario: Anonymous user sees no costs
    Given I am not logged in
    And there is 1 Project with the following:
      | Name      | Test |
    And the project "Test" has 1 cost entry
    And I am on the Cost Reports page for the project called "Test"
    Then I should see "Login:"
    And I should see "Password:"

  Scenario: Admin user sees everything
    Given I am admin
    And there is 1 project with the following:
      | Name | Test |
    And there is 1 cost type with the following:
      | name      | Translation |
      | cost rate | 1           |
    And the project "Test" has 1 cost entry with the following:
      | units | 424 |
    And the project "Test" has 1 time entries with the following:
      | hours | 11  |
    And I am on the Cost Reports page for the project called "Test" without filters or groups
    Then I should not see "No data to display"
    And I should see "424.00"
    And I should see "11.00 hours"
    And I should see "Translation"

  Scenario: User who can see own costs, ONLY sees own costs
    Given I am not logged in
    And there is 1 project with the following:
      | Name | Test |
    And there is 1 User with:
      | Login | bob |
      | Firstname | Bob |
      | Lastname | Bobbit |
    And the user "bob" is a "Developer" in the project "Test"
    And the role "Developer" may have the following rights:
      | View own cost entries |
    And there is 1 cost type with the following:
      | name      | Translation |
      | cost rate | 1           |
    And the user "bob" has 1 issue with the following:
      | subject | bobs issue |
    And the issue "bobs issue" has 1 cost entry with the following:
      | user      | bob         |
      | units     | 5           |
      | cost type | Translation |
    And there is 1 cost type with the following:
      | name | Hidden Costs |
    And the project "Test" has 1 cost entry with the following:
      | units | 128128 |
    And I am logged in as "bob"
    And I am on the Cost Reports page for the project called "Test"
    Then I should not see "No data to display"
    And I should see "5.00"          # 5 Translations x 10 EUR
    And I should not see "128128.00"  # The other cost entries
    And I should not see "128,128.00" # The other cost entries in american writing

  Scenario: User who can see own time entries, ONLY sees own time entries
    Given I am not logged in
    And there is 1 project with the following:
      | Name         | Test     |
    And there is 1 User with:
      | Login        | bob      |
      | Firstname    | Bob      |
      | Lastname     | Bobbit   |
      | default rate | 0.01     |
    And there is 1 User with:
      | Login        | charly   |
      | Firstname    | Charly   |
      | Lastname     | Charlson |
      | default rate | 1.00     |
    And the user "bob" is a "Developer" in the project "Test"
    And the role "Developer" may have the following rights:
      | View own time entries   |
    And the user "bob" has 1 time entry with 23 hours at the project "Test"
    And the user "charly" has 1 time entry with 11 hours at the project "Test"
    And I am logged in as "bob"
    And I am on the Cost Reports page for the project called "Test" without filters or groups
    Then I should not see "No data to display"
    And I should not see "0.00"
    And I should not see "11.00"
    But I should see "23.00 hours"

  Scenario: User who can see own time entries, see's his time, but not other's time, no money and no cost entries
    Given there is a standard cost control project named "testproject"
    And there is 1 cost type with the following:
      | name      | word |
      | cost rate | 1.01 |
    And users have times and the cost type "word" logged on the issue "testprojectissue" with:
      | manager rate    | 10.1 |
      | developer rate  | 10.2 |
      | manager hours   | 5    |
      | developer hours | 11   |
      | manager units   | 20   |
      | developer units | 10   |
    And the role "Manager" may have the following rights:
      | view_own_time_entries |
    And I am logged in as "manager"
    And I am on the Cost Reports page for the project called "testproject" without filters or groups
    Then I should not see "No data to display"
    And I should not see "193.00" # EUR 50.50 + 112.20 (manager + developer hours) + 20.20 + 10.10 (manager + developer words)
    And I should not see "30.30" # EUR 20.20 + 10.10 (manager + developer words)
    And I should not see "162.70" # EUR 50.50 + 112.20 (manager + developer hours)
    And I should not see "50.50" # EUR manager hours
    And I should not see "112.20" # EUR developer hours
    And I should not see "20.20" # EUR manager words
    And I should not see "10.10" # EUR developer words
    And I should not see "20.0" # Units manager words
    And I should not see "10.0" # Units developer words
    And I should not see "30.0" # Units manager + developer
    And I should not see "11.00" # Hours developer
    And I should not see "16.00" # Hours developer + manager
    And I should see "5.00" # Hours manager

  Scenario: User who can see time entries, see times, but no money and no cost entries
    Given there is a standard cost control project named "testproject"
    And there is 1 cost type with the following:
      | name      | word |
      | cost rate | 1.01 |
    And users have times and the cost type "word" logged on the issue "testprojectissue" with:
      | manager rate    | 10.1 |
      | developer rate  | 10.2 |
      | manager hours   | 5    |
      | developer hours | 11   |
      | manager units   | 20   |
      | developer units | 10   |
    And the role "Manager" may have the following rights:
      | view_time_entries |
    And I am logged in as "manager"
    And I am on the Cost Reports page for the project called "testproject" without filters or groups
    Then I should not see "No data to display"
    And I should not see "193.00" # EUR 50.50 + 112.20 (manager + developer hours) + 20.20 + 10.10 (manager + developer words)
    And I should not see "30.30" # EUR 20.20 + 10.10 (manager + developer words)
    And I should not see "162.70" # EUR 50.50 + 112.20 (manager + developer hours)
    And I should not see "50.50" # EUR manager hours
    And I should not see "112.20" # EUR developer hours
    And I should not see "20.20" # EUR manager words
    And I should not see "10.10" # EUR developer words
    And I should not see "20.0" # Units manager words
    And I should not see "10.0" # Units developer words
    And I should not see "30.0" # Units manager + developer
    And I should see "11.00" # Hours developer
    And I should see "16.00" # Hours developer + manager
    And I should see "5.00" # Hours manager

  Scenario: User who has all rights should see everything
    Given there is a standard cost control project named "testproject"
    And there is 1 cost type with the following:
      | name      | word |
      | cost rate | 1.01 |
    And users have times and the cost type "word" logged on the issue "testprojectissue" with:
      | manager rate    | 10.1 |
      | developer rate  | 10.2 |
      | manager hours   | 5    |
      | developer hours | 11   |
      | manager units   | 20   |
      | developer units | 10   |
    And the role "Manager" may have the following rights:
      | view_time_entries     |
      | view_cost_entries     |
      | view_own_time_entries |
      | view_own_cost_entries |
#     | view_hourly_rates     |
#     | view_cost_rates       |
#     | view_own_hourly_rate  |
    And I am logged in as "manager"
    And I am on the Cost Reports page for the project called "testproject" without filters or groups
    Then I should not see "No data to display"
    And I should see "193.00" # EUR 50.50 + 112.20 (manager + developer hours) + 20.20 + 10.10 (manager + developer words)
    And I should see "50.50" # EUR manager hours
    And I should see "112.20" # EUR developer hours
    And I should see "20.20" # EUR manager words
    And I should see "10.10" # EUR developer words
    And I should see "20.0" # Units manager words
    And I should see "10.0" # Units developer words
    And I should see "11.00" # Hours developer
    And I should see "5.00" # Hours manager

  Scenario: User who has no rights should see nothing
    Given there is a standard cost control project named "testproject"
    And there is 1 cost type with the following:
      | name      | word |
      | cost rate | 1.01 |
    And users have times and the cost type "word" logged on the issue "testprojectissue" with:
      | manager rate    | 10.1 |
      | developer rate  | 10.2 |
      | manager hours   | 5    |
      | developer hours | 11   |
      | manager units   | 20   |
      | developer units | 10   |
    And the role "Manager" may have the following rights:
      | no_rights |
    And I am logged in as "manager"
    And I am on the Cost Reports page for the project called "testproject" without filters or groups
    Then I should see "403" # "You are not authorized to access this page."
    And I should not see "193.00" # EUR 50.50 + 112.20 (manager + developer hours) + 20.20 + 10.10 (manager + developer words)
    And I should not see "50.50" # EUR manager hours
    And I should not see "112.20" # EUR developer hours
    And I should not see "20.20" # EUR manager words
    And I should not see "10.10" # EUR developer words
    And I should not see "20.0" # Units manager words
    And I should not see "10.0" # Units developer words
    And I should not see "11.00" # Hours developer
    And I should not see "5.00" # Hours manager

  Scenario: User who has only rights to see his own times (and to see all costs) should actually just do so
    Given there is a standard cost control project named "testproject"
    And there is 1 cost type with the following:
      | name      | word |
      | cost rate | 1.01 |
    And users have times and the cost type "word" logged on the issue "testprojectissue" with:
      | manager rate    | 10.1 |
      | developer rate  | 10.2 |
      | manager hours   | 5    |
      | developer hours | 11   |
      | manager units   | 20   |
      | developer units | 10   |
    And the role "Manager" may have the following rights:
#     | view_time_entries     |
      | view_cost_entries     |
      | view_own_time_entries |
      | view_own_cost_entries |
#     | view_hourly_rates     |
#     | view_cost_rates       |
#     | view_own_hourly_rate  |
    And I am logged in as "manager"
    And I am on the Cost Reports page for the project called "testproject" without filters or groups
    Then I should not see "No data to display"
    And I should not see "193.00" # EUR 50.50 + 112.20 (manager + developer hours) + 20.20 + 10.10 (manager + developer words)
    And I should see "50.50" # EUR manager hours
    And I should not see "112.20" # EUR developer hours
    And I should see "20.20" # EUR manager words
    And I should see "10.10" # EUR developer words
    And I should see "20.0" # Units manager words
    And I should see "10.0" # Units developer words
    And I should not see "11.00" # Hours developer
    And I should see "5.00" # Hours manager
    And I should see "80.80" # Sum of the costs (manager hours (50.50) + manager words (20.20) + developer words (10.10))

  Scenario: User who has only rights to see costs should actually just do so
    Given there is a standard cost control project named "testproject"
    And there is 1 cost type with the following:
      | name      | word |
      | cost rate | 1.01 |
    And users have times and the cost type "word" logged on the issue "testprojectissue" with:
      | manager rate    | 10.1 |
      | developer rate  | 10.2 |
      | manager hours   | 5    |
      | developer hours | 11   |
      | manager units   | 20   |
      | developer units | 10   |
    And the role "Manager" may have the following rights:
#     | view_time_entries     |
      | view_cost_entries     |
#     | view_own_time_entries |
      | view_own_cost_entries |
#     | view_hourly_rates     |
#     | view_cost_rates       |
#     | view_own_hourly_rate  |
    And I am logged in as "manager"
    And I am on the Cost Reports page for the project called "testproject" without filters or groups
    Then I should not see "No data to display"
    And I should not see "193.00" # EUR 50.50 + 112.20 (manager + developer hours) + 20.20 + 10.10 (manager + developer words)
    And I should not see "50.50" # EUR manager hours
    And I should not see "112.20" # EUR developer hours
    And I should see "20.20" # EUR manager words
    And I should see "10.10" # EUR developer words
    And I should see "20.0" # Units manager words
    And I should see "10.0" # Units developer words
    And I should not see "11.00" # Hours developer
    And I should not see "5.00" # Hours manager
    And I should see "30.30" # Sum of the costs (manager words (20.20) + developer words (10.10))

  Scenario: User who has only rights to see time and own costs should actually just do so
    Given there is a standard cost control project named "testproject"
    And there is 1 cost type with the following:
      | name      | word |
      | cost rate | 1.01 |
    And users have times and the cost type "word" logged on the issue "testprojectissue" with:
      | manager rate    | 10.1 |
      | developer rate  | 10.2 |
      | manager hours   | 5    |
      | developer hours | 11   |
      | manager units   | 20   |
      | developer units | 10   |
    And the role "Manager" may have the following rights:
      | view_time_entries     |
#     | view_cost_entries     |
      | view_own_time_entries |
      | view_own_cost_entries |
#     | view_hourly_rates     |
#     | view_cost_rates       |
#     | view_own_hourly_rate  |
    And I am logged in as "manager"
    And I am on the Cost Reports page for the project called "testproject" without filters or groups
    Then I should not see "No data to display"
    And I should not see "193.00" # EUR 50.50 + 112.20 (manager + developer hours) + 20.20 + 10.10 (manager + developer words)
    And I should see "50.50" # EUR manager hours
    And I should see "112.20" # EUR developer hours
    And I should see "20.20" # EUR manager words
    And I should not see "10.10" # EUR developer words
    And I should see "20.0" # Units manager words
    And I should not see "10.0" # Units developer words
    And I should see "11.00" # Hours developer
    And I should see "5.00" # Hours manager
#########
# ab hier wirds falsch
# aber vorher sind die dinge, die mit rates zu tun haben auch schon falsch (oder es muss mindestens überprüft werden)
#########
    And I should see "30.30" # Sum of the costs (manager words (20.20) + developer words (10.10))

  Scenario: User who has only rights to see own costs and own times should actually just do so
    Given there is a standard cost control project named "testproject"
    And there is 1 cost type with the following:
      | name      | word |
      | cost rate | 1.01 |
    And users have times and the cost type "word" logged on the issue "testprojectissue" with:
      | manager rate    | 10.1 |
      | developer rate  | 10.2 |
      | manager hours   | 5    |
      | developer hours | 11   |
      | manager units   | 20   |
      | developer units | 10   |
    And the role "Manager" may have the following rights:
#     | view_time_entries     |
#     | view_cost_entries     |
      | view_own_time_entries |
      | view_own_cost_entries |
#     | view_hourly_rates     |
#     | view_cost_rates       |
#     | view_own_hourly_rate  |
    And I am logged in as "manager"
    And I am on the Cost Reports page for the project called "testproject" without filters or groups
    Then I should not see "No data to display"
    And I should not see "193.00" # EUR 50.50 + 112.20 (manager + developer hours) + 20.20 + 10.10 (manager + developer words)
    And I should see "50.50" # EUR manager hours
    And I should not see "112.20" # EUR developer hours
    And I should see "20.20" # EUR manager words
    And I should not see "10.10" # EUR developer words
    And I should see "20.0" # Units manager words
    And I should not see "10.0" # Units developer words
    And I should not see "11.00" # Hours developer
    And I should see "5.00" # Hours manager
    And I should see "30.30" # Sum of the costs (manager words (20.20) + developer words (10.10))