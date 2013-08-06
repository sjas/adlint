Feature: W0459

  W0459 detects that the variable is not initialized at point of the expression
  evaluation.

  Scenario: variable initialization by a function via the output parameter
    Given a target source named "fixture.c" with:
      """
      extern void foo(int ***);
      extern void bar(int **);

      void baz(int i)
      {
          int **p;
          foo(i == 0 ? NULL : &p);
          bar(p);
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0118 | 2    | 13     |
      | W0117 | 4    | 6      |
      | W0459 | 7    | 25     |
      | C1000 |      |        |
      | C1003 | 6    | 11     |
      | W0100 | 6    | 11     |
      | W0104 | 4    | 14     |
      | W0501 | 7    | 16     |
      | W0628 | 4    | 6      |

  Scenario: reference to the uninitialized nested array element of the
            indefinite subscript
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int a[3][3]; /* W0100 */
          return a[i][i]; /* W0459 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0705 | 4    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 13     |
      | W0705 | 4    | 17     |
      | C1000 |      |        |
      | C1006 | 1    | 13     |
      | W0459 | 4    | 16     |
      | C1000 |      |        |
      | C1003 | 3    | 9      |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 13     |
      | W0950 | 3    | 14     |
      | W0950 | 3    | 11     |
      | W0628 | 1    | 5      |

  Scenario: reference to the initialized array element of the indefinite
            subscript
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int a[3] = { 0 };

          if (i < 3) {
              return a[i]; /* OK not W0459 */
          }
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0705 | 6    | 18     |
      | C1000 |      |        |
      | C1006 | 1    | 13     |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 13     |
      | W1071 | 1    | 5      |
      | W0950 | 3    | 11     |
      | W0628 | 1    | 5      |

  Scenario: assign value to the variable in a switch-statement in an
            iteration-statement
    Given a target source named "fixture.c" with:
      """
      extern void bar(int *);

      int foo(int a[])
      {
          int i;
          int j;

          for (i = 0; a[i]; i++) {
              switch (a[i]) {
              case 0:
                  bar(&j);
                  break;
              case 2:
                  bar(&j);
                  break;
              default:
                  break;
              }
          }

          return j; /* OK but W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 5      |
      | W0459 | 14   | 17     |
      | C1000 |      |        |
      | C1003 | 6    | 9      |
      | W0460 | 21   | 12     |
      | C1000 |      |        |
      | C1003 | 6    | 9      |
      | C1001 | 8    | 18     |
      | C1002 | 13   | 9      |
      | W0104 | 3    | 13     |
      | W9001 | 10   | 9      |
      | W9001 | 11   | 13     |
      | W9001 | 12   | 13     |
      | W0114 | 8    | 5      |
      | W0628 | 3    | 5      |
