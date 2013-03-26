Feature: W0606

  W0606 detects that floating point in union.

  Scenario: floating point in union
    Given a target source named "fixture.c" with:
      """
      union UNI { /* W0606 */
          float a;
          int b;
      };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0551 | 1    | 7      |
      | W0606 | 1    | 7      |
