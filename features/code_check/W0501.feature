Feature: W0501

  W0501 detects that a binary-expression appars in a conditional-expression
  without appropriate grouping.

  Scenario: binary-expressions in a conditional-expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c)
      {
          return a + b ? a + b : c; /* W0501 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0723 | 3    | 22     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0629 | 1    | 12     |
      | W0501 | 3    | 18     |
      | W0114 | 3    | 14     |
      | W0628 | 1    | 12     |

  Scenario: binary-expressions in a conditional-expression with grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c)
      {
          return (a + b) ? (a + b) : c; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 15     |
      | W0723 | 3    | 25     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0629 | 1    | 12     |
      | W0114 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: binary-expressions in a conditional-expression with large grouping
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c)
      {
          return (a + b ? a + b : c); /* W0501 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 15     |
      | W0723 | 3    | 23     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0629 | 1    | 12     |
      | W0501 | 3    | 19     |
      | W0114 | 3    | 15     |
      | W0628 | 1    | 12     |
