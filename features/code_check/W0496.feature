Feature: W0496

  W0496 detects that multiple conditional-expressions appear in an expression
  without appropriate grouping.

  Scenario: without grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return a < 0 ? a : b > 0 ? a + b : b; /* W0496 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 34     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0496 | 3    | 12     |
      | W0501 | 3    | 18     |
      | W0628 | 1    | 12     |

  Scenario: with appropriate grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return a < 0 ? a : (b > 0 ? a + b : b); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 35     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0501 | 3    | 18     |
      | W0628 | 1    | 12     |

  Scenario: entirely grouped
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b)
      {
          return (a < 0 ? a : b > 0 ? a + b : b); /* W0496 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 35     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0629 | 1    | 12     |
      | W0496 | 3    | 13     |
      | W0501 | 3    | 19     |
      | W0628 | 1    | 12     |
