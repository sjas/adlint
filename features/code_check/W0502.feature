Feature: W0502

  W0502 detects that operators of the different priority except for `+', `-',
  `*', `/' and `%' appear in an expression without appropriate grouping.

  Scenario: shift-expression and and-expression in an expression
    Given a target source named "fixture.c" with:
      """
      static unsigned int foo(unsigned int a, unsigned int b, unsigned int c)
      {
          return a << b & c; /* W0502 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 21     |
      | W0116 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 38     |
      | W0104 | 1    | 38     |
      | W0104 | 1    | 54     |
      | W0104 | 1    | 70     |
      | W0629 | 1    | 21     |
      | W0502 | 3    | 12     |
      | W0628 | 1    | 21     |

  Scenario: shift-expression and and-expression in an expression with grouping
    Given a target source named "fixture.c" with:
      """
      static unsigned int foo(unsigned int a, unsigned int b, unsigned int c)
      {
          return a << (b & c); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 21     |
      | W0116 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 38     |
      | W0104 | 1    | 38     |
      | W0104 | 1    | 54     |
      | W0104 | 1    | 70     |
      | W0629 | 1    | 21     |
      | W0628 | 1    | 21     |

  Scenario: shift-expression and and-expression in an expression with large
            grouping
    Given a target source named "fixture.c" with:
      """
      static unsigned int foo(unsigned int a, unsigned int b, unsigned int c)
      {
          return (a << b & c); /* W0502 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 21     |
      | W0116 | 3    | 15     |
      | C1000 |      |        |
      | C1006 | 1    | 38     |
      | W0104 | 1    | 38     |
      | W0104 | 1    | 54     |
      | W0104 | 1    | 70     |
      | W0629 | 1    | 21     |
      | W0502 | 3    | 12     |
      | W0628 | 1    | 21     |
