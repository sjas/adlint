Feature: W0698

  W0698 detects that a `return' statement without expression is found in a
  non-void function.

  Scenario: returning nothing from `int' function
    Given a target source named "fixture.c" with:
      """
      int func(void)
      {
          return; /* W0698 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0698 | 3    | 5      |
      | W0628 | 1    | 5      |
