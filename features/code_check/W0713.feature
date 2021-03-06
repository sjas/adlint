Feature: W0713

  W0713 detects that operands of both sides of relational expression is
  `effectively boolean'.

  Scenario: relational expressions
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a > b) > (c > d); /* W0713 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0713 | 3    | 20     |
      | W0628 | 1    | 12     |

  Scenario: an equality expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a == b) > (c != d); /* W0713 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0713 | 3    | 21     |
      | W0628 | 1    | 12     |

  Scenario: logical expressions
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a && b) > (c || d); /* W0713 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0713 | 3    | 21     |
      | W0628 | 1    | 12     |

  Scenario: shift expressions
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a << b) > (c ^ d); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0570 | 3    | 15     |
      | C1000 |      |        |
      | C1006 | 1    | 20     |
      | W0572 | 3    | 15     |
      | W0794 | 3    | 15     |
      | W0572 | 3    | 26     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: arithmetic expressions
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a + b) > (c - d); /* OK */
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
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |
