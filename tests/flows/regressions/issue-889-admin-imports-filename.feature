Feature: Admin Imports page shows filenames for all imports (#889)
  Regression for https://github.com/CLOSER-Cohorts/archivist/issues/889
  — the filename column on /admin/imports must show the actual filename
  for every row, including imports whose document_id has been cleaned up
  by the after_update hook on Import.

  Scenario: Admin imports page shows filenames not "No document"
    When I log in as "simon.reed@browsergroup.com" with password "Password123!"
    And I navigate to "/admin/imports"
    And I wait for the page to settle
    Then I should not see "No document"
