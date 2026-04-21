Feature: Remove inert DV and Topics buttons from Admin Datasets (#881)
  Regression for https://github.com/CLOSER-Cohorts/archivist/issues/881
  — the DV and Topics buttons on the admin datasets list render nothing
  interactive and should be removed. The remaining action buttons must
  still render (verified by table data being present).

  Scenario: DV and Topics buttons are absent from Admin Datasets page
    When I log in as "simon.reed@browsergroup.com" with password "Password123!"
    And I navigate to "/admin/datasets"
    And I wait for the page to settle
    Then I should see "Rows per page:"
    And I should not see "DV"
    And I should not see "Topics"
