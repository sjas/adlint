Feature: W0481

  W0481 detects that the macro is enclosed by `{}' and have semicolon.

  Scenario: enclosed by `{}' and have code block
    Given a target source named "fixture.c" with:
      """
      #define INI(x, n) {int i;for (i=0; i < n; ++i) { x[i] = 0; }} /* W0481 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0549 | 1    | 50     |
      | W0549 | 1    | 40     |
      | W0481 | 1    | 1      |

  Scenario: enclosed by `{}', but it's not code block
    Given a target source named "fixture.c" with:
      """
      #define INI(x, n) { (x) + (n) } /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
