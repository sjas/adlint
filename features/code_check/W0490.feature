Feature: W0490

  W0490 detects that multiple precedence binary-expressions appear as an
  operand of a logical-and-expression or a logical-or-expression without
  appropriate grouping.

  Scenario: precedence binary-expressions appear as an operand of a
            logical-and-expression
    Given a target source named "fixture.c" with:
      """
      static void foo(int i, int j)
      {
          if (i + j && i * j) { /* W0490 */
              return;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 3    | 11     |
      | W0723 | 3    | 20     |
      | W0104 | 1    | 21     |
      | W0104 | 1    | 28     |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0490 | 3    | 9      |
      | W0500 | 3    | 9      |
      | W0502 | 3    | 9      |
      | W0732 | 3    | 15     |
      | W0628 | 1    | 13     |

  Scenario: precedence binary-expressions appear as an operand of a
            logical-and-expression with grouping
    Given a target source named "fixture.c" with:
      """
      static void foo(int i, int j)
      {
          if ((i + j) && (i * j)) { /* OK */
              return;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 3    | 12     |
      | W0723 | 3    | 23     |
      | W0104 | 1    | 21     |
      | W0104 | 1    | 28     |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0732 | 3    | 17     |
      | W0628 | 1    | 13     |

  Scenario: precedence binary-expressions appear as an operand of a
            logical-and-expression grouped entirely
    Given a target source named "fixture.c" with:
      """
      static void foo(int i, int j)
      {
          if ((i + j && i * j)) { /* W0490 */
              return;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0723 | 3    | 12     |
      | W0723 | 3    | 21     |
      | W0104 | 1    | 21     |
      | W0104 | 1    | 28     |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0490 | 3    | 9      |
      | W0500 | 3    | 9      |
      | W0502 | 3    | 9      |
      | W0732 | 3    | 16     |
      | W0628 | 1    | 13     |
