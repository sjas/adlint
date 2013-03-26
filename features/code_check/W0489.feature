Feature: W0489

  W0489 detects that multiple unary-expressions appear as an operand of a
  logical-and-expression or a logical-or-expression without appropriate
  grouping.

  Scenario: unary-expressions appear as an operand of a logical-and-expression
    Given a target source named "fixture.c" with:
      """
      static void foo(int i, int *p)
      {
          if (p) {
              if (-i++ && !*p) { /* W0489 */
                  return;
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0104 | 1    | 29     |
      | W0105 | 1    | 29     |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0489 | 4    | 13     |
      | W0114 | 3    | 5      |
      | W0628 | 1    | 13     |

  Scenario: unary-expressions appear as an operand of a logical-and-expression
            with grouping
    Given a target source named "fixture.c" with:
      """
      static void foo(int i, int *p)
      {
          if (p) {
              if ((-i++) && (!*p)) { /* OK */
                  return;
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0104 | 1    | 29     |
      | W0105 | 1    | 29     |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0114 | 3    | 5      |
      | W0628 | 1    | 13     |

  Scenario: unary-expressions appear as an operand of a logical-and-expression
            grouped entirely
    Given a target source named "fixture.c" with:
      """
      static void foo(int i, int *p)
      {
          if (p) {
              if ((-i++ && !*p)) { /* W0489 */
                  return;
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0104 | 1    | 29     |
      | W0105 | 1    | 29     |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0489 | 4    | 13     |
      | W0114 | 3    | 5      |
      | W0628 | 1    | 13     |
