Feature: W0699

  W0699 detects that`return;' statement is found at except void function.

  Scenario: return statement
    Given a target source named "fixture.c" with:
      """
      extern func(void)
      {
          return; /* W0699 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 8      |
      | W0700 | 1    | 8      |
      | W0457 | 1    | 8      |
      | W0699 | 3    | 5      |
      | W0628 | 1    | 8      |
