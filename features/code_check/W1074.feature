Feature: W1074

  W1074 detects that an expression with possible side-effects appears in the
  `sizeof' expression.

  Scenario: postfix-increment-expression in the sizeof-expression
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int i = 0;

          if (sizeof(i++) == 4) { /* W1074 */
              return 0;
          }
          else {
              return 1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0168 | 5    | 24     |
      | W0609 | 5    | 21     |
      | W0612 | 5    | 21     |
      | W0100 | 3    | 9      |
      | W0629 | 1    | 12     |
      | W1074 | 5    | 15     |
      | W9001 | 9    | 9      |
      | W0628 | 1    | 12     |

  Scenario: nested sizeof-expression
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int i = 0;

          if (sizeof(1 + sizeof(i++)) == 5) { /* W1074 */
              return 0;
          }
          else {
              return 1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0168 | 5    | 36     |
      | W0610 | 5    | 33     |
      | W0613 | 5    | 33     |
      | W0100 | 3    | 9      |
      | W0629 | 1    | 12     |
      | W1074 | 5    | 26     |
      | W9001 | 6    | 9      |
      | W0628 | 1    | 12     |

  Scenario: ungrouped postfix-increment-expression in the sizeof-expression
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int i = 0;

          if (sizeof i++ == 4) { /* W1074 */
              return 0;
          }
          else {
              return 1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0168 | 5    | 23     |
      | W0609 | 5    | 20     |
      | W0612 | 5    | 20     |
      | W0100 | 3    | 9      |
      | W0629 | 1    | 12     |
      | W1074 | 5    | 17     |
      | W9001 | 9    | 9      |
      | W0628 | 1    | 12     |

  Scenario: function-call-expression in the sizeof-expression
    Given a target source named "fixture.c" with:
      """
      extern int bar(void);

      static int foo(void)
      {
          if (sizeof(bar()) == 4) { /* W1074 */
              return 0;
          }
          else {
              return 1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1076 | 3    | 12     |
      | W0168 | 5    | 26     |
      | W0609 | 5    | 23     |
      | W0612 | 5    | 23     |
      | W0629 | 3    | 12     |
      | W1074 | 5    | 15     |
      | W9001 | 9    | 9      |
      | W0628 | 3    | 12     |

  Scenario: array-subscript-expression in the sizeof-expression
    Given a target source named "fixture.c" with:
      """
      extern int a[];

      static int foo(void)
      {
          if (sizeof(a[0]) == 4) { /* OK */
              return 0;
          }
          else {
              return 1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1077 | 1    | 12     |
      | W1076 | 3    | 12     |
      | W0168 | 5    | 25     |
      | W0609 | 5    | 22     |
      | W0612 | 5    | 22     |
      | W0629 | 3    | 12     |
      | W9001 | 9    | 9      |
      | W0628 | 3    | 12     |
