Feature: Trash icon removes a code list option (#888)
  Regression for https://github.com/CLOSER-Cohorts/archivist/issues/888
  — clicking the trash icon next to a code option must remove the row
  from the form, and saving must persist the deletion.

  Scenario: Trash icon removes a code from an existing code list
    When I log in as "simon.reed@browsergroup.com" with password "Password123!"
    And I navigate to "/instruments/nshd_61_ci/build/code_lists/43875"
    And I wait for the page to settle
    And I should see "213050"
    And I click the "Delete code 1" button
    And I click the "Save" button
    And I wait for the page to settle
    And I navigate to "/instruments/nshd_61_ci/build/code_lists/43875"
    And I wait for the page to settle
    Then I should not see "213050"
