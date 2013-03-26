Feature: W0716

  W0716 detects that operands of both sides of bitwise expression or arithmetic
  expression are `effectively boolean'.

  Scenario: an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a > b) + (c > d); /* W0716 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 20     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0716 | 3    | 20     |
      | W0628 | 1    | 12     |

  Scenario: a bitwise expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a > b) ^ (c > d); /* W0716 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0572 | 3    | 20     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0716 | 3    | 20     |
      | W0628 | 1    | 12     |

  Scenario: a shift expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int a, int b, int c, int d)
      {
          return (a > b) << (c > d); /* W0716 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0570 | 3    | 20     |
      | W0572 | 3    | 20     |
      | W0794 | 3    | 20     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W0104 | 1    | 41     |
      | W0629 | 1    | 12     |
      | W0716 | 3    | 20     |
      | W0628 | 1    | 12     |
