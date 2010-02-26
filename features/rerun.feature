Feature: Rerun Formatter

  Scenario: Rerun formatter generates rerun.txt with failed features
     When I run `testjour --rerun failing.feature`
     Then rerun.txt should include "failing.feature"

  Scenario: No rerun.txt is generated with rerun formatter if all features are successful
    When I run `testjour --rerun passing.feature`
    Then rerun.txt should not include "passing.feature"

  Scenario: Rerun formatter generates rerun.txt with multiple failed features
     When I run `testjour --rerun failing.feature failing2.feature passing.feature`
     Then rerun.txt should include "failing.feature failing2.feature"
     Then rerun.txt should not include "passing.feature"

  Scenario: Rerun formatter rerun.txt is empty after running failed features then passing features
    When I run `testjour --rerun failing.feature`
    And I run `testjour --rerun passing.feature`
    Then rerun.txt should not include "failing.feature"
    And rerun.txt should not include "passing.feature"

  Scenario: Without rerun formatter rerun.txt is not generated
    When I run `testjour failing.feature passing.feature`
    Then rerun.txt should not exist