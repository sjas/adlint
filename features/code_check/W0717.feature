Feature: W0717

  W0717 detects that operand of left side of bitwise expression or arithmetic
  expression is `effectively boolean'.

  Scenario: an arithmetic expression
    Given a target source named "fixture.c" with:
      """
      static int func(int a, int b, int c)
      {
          return (a > b) + c; /* W0717 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 20     |
      | W0104 | 1    | 21     |
      | W0104 | 1    | 28     |
      | W0104 | 1    | 35     |
      | W0629 | 1    | 12     |
      | W0717 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: a bitwise expression
    Given a target source named "fixture.c" with:
      """
      static int func(int a, int b, int c)
      {
          return (a > b) ^ c; /* W0717 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0572 | 3    | 20     |
      | W0104 | 1    | 21     |
      | W0104 | 1    | 28     |
      | W0104 | 1    | 35     |
      | W0629 | 1    | 12     |
      | W0717 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: a shift expression
    Given a target source named "fixture.c" with:
      """
      static int func(int a, int b, int c)
      {
          return (a > b) << c; /* W0717 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0570 | 3    | 20     |
      | W0572 | 3    | 20     |
      | W0794 | 3    | 20     |
      | W0104 | 1    | 21     |
      | W0104 | 1    | 28     |
      | W0104 | 1    | 35     |
      | W0629 | 1    | 12     |
      | W0717 | 3    | 12     |
      | W0628 | 1    | 12     |
