Feature: Create code list with multiple codes in one submit (#878)
  Regression for https://github.com/CLOSER-Cohorts/archivist/issues/878
  — creating a brand-new code list with two or more codes in a single
  submit must succeed. The create path previously omitted order on each
  code; the update path correctly assigned it.

  Scenario: New code list with 2 codes saves on first submit
    When I log in as "simon.reed@browsergroup.com" with password "Password123!"
    And I navigate to "/instruments/mcs_18_ypsc/build/code_lists/new"
    And I wait for the page to settle
    And I fill in the code list label with "yesno-issue-878" and a unique suffix
    And I click the add code button
    And I fill in the code row 1 with value "1" and label "Yes"
    And I click the add code button
    And I fill in the code row 2 with value "2" and label "No"
    And I click the "Save" button
    And I wait for the URL to match "code_lists/\d+"
    And I wait for the code list to load
    Then the code row 1 should have label "Yes"
    And the code row 2 should have label "No"
