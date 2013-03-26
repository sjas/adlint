Feature: W0488

  W0488 detects that multiple function-call-expressions or
  member-access-expressions or array-subscript-expressions appear in a
  logical-and-expression or a logical-or-expression without appropriate
  grouping.

  Scenario: member-access-expression and array-subscript-expression and
            function-call-expression as an operand of logical-and-expression
    Given a target source named "fixture.c" with:
      """
      struct foo { int (*a[3])(void); };

      static void foo(struct foo *p)
      {
          if (p) {
              if (p->a[0]() && p->a[1]()) { /* W0488 */
                  return;
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 13     |
      | W0104 | 3    | 29     |
      | W0105 | 3    | 29     |
      | W1071 | 3    | 13     |
      | W0629 | 3    | 13     |
      | W0488 | 6    | 13     |
      | W0508 | 6    | 23     |
      | W0114 | 5    | 5      |
      | W0628 | 3    | 13     |

  Scenario: member-access-expression and array-subscript-expression and
            function-call-expression as an operand of logical-and-expression
            with grouping
    Given a target source named "fixture.c" with:
      """
      struct foo { int (*a[3])(void); };

      static void foo(struct foo *p)
      {
          if (p) {
              if (((p->a[0])()) && ((p->a[1])())) { /* OK */
                  return;
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 13     |
      | W0104 | 3    | 29     |
      | W0105 | 3    | 29     |
      | W1071 | 3    | 13     |
      | W0629 | 3    | 13     |
      | W0508 | 6    | 27     |
      | W0114 | 5    | 5      |
      | W0628 | 3    | 13     |

  Scenario: member-access-expression and array-subscript-expression and
            function-call-expression as an operand of logical-and-expression
            grouped entirely
    Given a target source named "fixture.c" with:
      """
      struct foo { int (*a[3])(void); };

      static void foo(struct foo *p)
      {
          if (p) {
              if ((p->a[0]() && p->a[1]())) { /* W0488 */
                  return;
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 13     |
      | W0104 | 3    | 29     |
      | W0105 | 3    | 29     |
      | W1071 | 3    | 13     |
      | W0629 | 3    | 13     |
      | W0488 | 6    | 13     |
      | W0508 | 6    | 24     |
      | W0114 | 5    | 5      |
      | W0628 | 3    | 13     |

  Scenario: ungrouped array-subscript-expression in a logical-and-expression
    Given a target source named "fixture.c" with:
      """
      static void foo(int i, int a[])
      {
          if (i && a[0]) { /* W0488 */
              return;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0104 | 1    | 21     |
      | W0104 | 1    | 28     |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0488 | 3    | 9      |
      | W0628 | 1    | 13     |

  Scenario: grouped array-subscript-expression in a logical-and-expression
    Given a target source named "fixture.c" with:
      """
      static void foo(int i, int a[])
      {
          if (i && (a[0])) { /* OK */
              return;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0104 | 1    | 21     |
      | W0104 | 1    | 28     |
      | W1071 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0628 | 1    | 13     |
