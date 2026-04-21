Feature: Partial QV import is flagged as failure (#887)
  Regression for https://github.com/CLOSER-Cohorts/archivist/issues/887
  — a QV import that does not cover every question in the instrument
  must end up with state "failure" and have log entries for every
  unmapped question so reviewers can see what is missing.

  Scenario: Partial QV import shows state failure and logs missing questions
    When I log in as "simon.reed@browsergroup.com" with password "Password123!"
    And I navigate to "/admin/instruments/1179/imports"
    And I wait for the page to settle
    Then I should see "failure"
    And I should not see "success"
