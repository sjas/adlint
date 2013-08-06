Feature: W0711

  W0711 detects that operand of right side of relational expression is
  `effectively boolean'.

  Scenario: a relational expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a + b) > (c > d); /* W0711 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 15     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0711 | 3    | 22     |
      | W0628 | 1    | 12     |

  Scenario: an equality expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a + b) > (c == d); /* W0711 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 15     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0711 | 3    | 22     |
      | W0628 | 1    | 12     |

  Scenario: a logical expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a + b) > (c && d); /* W0711 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 15     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0711 | 3    | 22     |
      | W0628 | 1    | 12     |

  Scenario: a shift expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a + b) > (c << d); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 15     |
      | W0570 | 3    | 25     |
      | C1000 |      |        |
      | C1006 | 1    | 34     |
      | W0572 | 3    | 25     |
      | W0794 | 3    | 25     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a + b) > (c + d); /* OK */
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
