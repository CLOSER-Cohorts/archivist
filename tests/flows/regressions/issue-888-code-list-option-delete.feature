Feature: Trash icon removes a code list option (#888)
  Regression for https://github.com/CLOSER-Cohorts/archivist/issues/888
  — clicking the trash icon next to a code option must remove the row
  from the form, and saving must persist the deletion.

  Background:
    Given I log in as "simon.reed@browsergroup.com" with password "Password123!"

  Scenario: Trash icon removes a saved code via direct URL
    When I navigate to "/instruments/ns_09_w6/build/code_lists/90968"
    And I wait for the page to settle
    And I should see "460306"
    And I click the "Delete code 1" button
    And I click the "Save" button
    And I wait for the page to settle
    And I navigate to "/instruments/ns_09_w6/build/code_lists/90968"
    And I wait for the page to settle
    Then I should not see "460306"

  Scenario: Trashing two saved codes in one save deletes both server-side
    When I navigate to "/instruments/ns_09_w6/build/code_lists/90970"
    And I wait for the page to settle
    And I should see "460307"
    And I should see "460308"
    And I click the "Delete code 3" button
    And I click the "Delete code 4" button
    And I click the "Save" button
    And I wait for the page to settle
    And I navigate to "/instruments/ns_09_w6/build/code_lists/90970"
    And I wait for the page to settle
    Then I should not see "460307"
    And I should not see "460308"

  Scenario: Delete-then-readd saves cleanly without constraint conflict
    When I navigate to "/instruments/ns_09_w6/build/code_lists/90971"
    And I wait for the page to settle
    And I should see "460309"
    And I click the "Delete code 1" button
    And I add a code with value "1" and label "Yes"
    And I click the "Save" button
    And I wait for the page to settle
    And I navigate to "/instruments/ns_09_w6/build/code_lists/90971"
    And I wait for the page to settle
    Then I should see input with value "Yes"

  Scenario: Trashing a newly added unsaved row discards it locally without server call
    When I navigate to "/instruments/ns_09_w6/build/code_lists/90972"
    And I wait for the page to settle
    And I should see "459167"
    And I click the "Add code" button
    And I click the "Delete code undefined" button
    And I click the "Save" button
    And I wait for the page to settle
    Then I should see "459167"

  Scenario: Feature is reachable via standard navigation from the instrument build page
    When I navigate to "/instruments/ns_09_w6/build"
    And I wait for the page to settle
    And I click the "Code Lists" link
    And I wait for the page to settle
    And I click on the list item "cs_NVQSub"
    And I wait for the page to settle
    Then the URL should match "/instruments/ns_09_w6/build/code_lists/90968"
