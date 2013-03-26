Feature: W0499

  W0499 detects that different operators of the same priority except for `+',
  `-', `*', `/' and `%' appear in an expression without appropriate grouping.

  Scenario: multiple shift-expressions in an expression
    Given a target source named "fixture.c" with:
      """
      static unsigned int foo(unsigned int a, unsigned int b, unsigned int c)
      {
          return a << b >> c; /* W0499 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 21     |
      | W0116 | 3    | 14     |
      | W0104 | 1    | 38     |
      | W0104 | 1    | 54     |
      | W0104 | 1    | 70     |
      | W0629 | 1    | 21     |
      | W0499 | 3    | 12     |
      | W0628 | 1    | 21     |

  Scenario: multiple shift-expressions in an expression with grouping
    Given a target source named "fixture.c" with:
      """
      static unsigned int foo(unsigned int a, unsigned int b, unsigned int c)
      {
          return (a << b) >> c; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 21     |
      | W0116 | 3    | 15     |
      | W0104 | 1    | 38     |
      | W0104 | 1    | 54     |
      | W0104 | 1    | 70     |
      | W0629 | 1    | 21     |
      | W0628 | 1    | 21     |

  Scenario: multiple shift-expressions in an expression with large grouping
    Given a target source named "fixture.c" with:
      """
      static unsigned int foo(unsigned int a, unsigned int b, unsigned int c)
      {
          return (a << b >> c); /* W0499 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 21     |
      | W0116 | 3    | 15     |
      | W0104 | 1    | 38     |
      | W0104 | 1    | 54     |
      | W0104 | 1    | 70     |
      | W0629 | 1    | 21     |
      | W0499 | 3    | 12     |
      | W0628 | 1    | 21     |
