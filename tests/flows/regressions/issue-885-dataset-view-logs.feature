Feature: Dataset import "View logs" button lands on the log page (#885)
  Regression for https://github.com/CLOSER-Cohorts/archivist/issues/885
  — visiting /admin/datasets/:id/imports/:import_id must open the import
  log. Before the fix it silently redirected to /admin/instruments/ because
  AdminDatasetImportMappingView destructured dataset_id instead of datasetId
  from useParams, producing an API call with `undefined` and triggering the
  axios 404 interceptor.

  Scenario: Dataset import detail page renders the log table
    When I log in as "simon.reed@browsergroup.com" with password "Password123!"
    And I navigate to "/admin/datasets/281/imports/338"
    And I wait for the page to settle
    Then the URL should match "/admin/datasets/281/imports/338"
    And I should see "Input"
    And I should see "Matches"
    And I should see "Outcome"
