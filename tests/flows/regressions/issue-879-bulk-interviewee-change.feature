Feature: Bulk change Interviewee on instrument constructs page (#879)
  Feature request: from the Build > Constructs page, an admin can
  change the Interviewee (ResponseUnit) on every question in the
  instrument in a single operation.

  Background:
    Given I log in as "simon.reed@browsergroup.com" with password "Password123!"

  Scenario: Button is visible and opens the bulk-change modal
    When I navigate to "/instruments/mcs_12_co/build/constructs"
    And I wait for the page to settle
    Then I should see "Expand All"
    And I should see "Collapse All"
    And I should see "Change Interviewee"

  Scenario: Submitting the modal updates every question
    When I navigate to "/instruments/mcs_12_co/build/constructs"
    And I wait for the page to settle
    And I click the "Change Interviewee" button
    And I select "Main parent of cohort/sample member" from the "Interviewee" dropdown
    And I click the "Apply" button
    And I wait for the page to settle
    Then I should see "11 questions updated successfully"
