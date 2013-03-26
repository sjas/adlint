Feature: W0599

  W0599 detects that value of the variable is referred and updated between
  sequence-points.

  Scenario: return-expression in a for-statement
    Given a target source named "fixture.c" with:
      """
      extern void bar(int, int, int);

      static void foo(int a, int b, int *c)
      {
          b = (a + 1) + a++; /* W0599 */
          b = c[a] + c[++a]; /* W0599 */
          bar(a, a++, c[a]); /* W0599 */
          bar(a, a, c[a++]); /* W0599 */
          a = a + b;
          c[a] = a++ + b; /* W0599 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W1076 | 3    | 13     |
      | W0723 | 5    | 12     |
      | W0723 | 5    | 17     |
      | W0599 | 5    | 7      |
      | W0422 | 6    | 10     |
      | W0422 | 6    | 17     |
      | W0723 | 6    | 14     |
      | W0599 | 6    | 7      |
      | W0422 | 7    | 18     |
      | W0599 | 7    | 8      |
      | W0422 | 8    | 16     |
      | W0723 | 9    | 11     |
      | W0422 | 10   | 6      |
      | W0723 | 10   | 16     |
      | W0599 | 10   | 10     |
      | W0104 | 3    | 36     |
      | W0629 | 3    | 13     |
      | W0512 | 5    | 20     |
      | W0512 | 6    | 18     |
      | W0512 | 7    | 13     |
      | W0512 | 8    | 18     |
      | W0512 | 10   | 13     |
      | W0628 | 3    | 13     |

  Scenario: return-expression in a for-statement
    Given a target source named "fixture.c" with:
      """
      static int foo(int x, int y, int z)
      {
          for (int i = 0; i < z; i++) { /* OK */
              if (x < y) {
                  return i;
              }
          }
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 20     |
      | W0104 | 1    | 27     |
      | W0104 | 1    | 34     |
      | W1071 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: object-specifier as a controlling expression and updating same
            variable in the branch
    Given a target source named "fixture.c" with:
      """
      static void foo(int i)
      {
          if (i) {
              i++; /* OK */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0114 | 3    | 5      |
      | W0628 | 1    | 13     |

  Scenario: assignment-expression as a controlling expression and updating same
            variable in the branch
    Given a target source named "fixture.c" with:
      """
      extern int bar(void);

      static void foo(int i)
      {
          while (i = bar()) {
              i++; /* OK */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1076 | 3    | 13     |
      | W0629 | 3    | 13     |
      | W0108 | 5    | 14     |
      | W0114 | 5    | 5      |
      | W0628 | 3    | 13     |

  Scenario: assignment-expression as a controlling expression and updating same
            variable in the branch
    Given a target source named "fixture.c" with:
      """
      extern int bar(int);

      static void foo(void)
      {
          int i;
          for (i = 0; i = bar(i); ) {
              i++; /* OK */
          }
          i++; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1076 | 3    | 13     |
      | W0708 | 7    | 10     |
      | W0629 | 3    | 13     |
      | W0108 | 6    | 19     |
      | W0114 | 6    | 5      |
      | W0628 | 3    | 13     |

  Scenario: updating variable in the 1st expression of conditional-expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int i)
      {
          return i++ ? i : 0; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0114 | 3    | 13     |
      | W0628 | 1    | 12     |

  Scenario: updating variable in the 1st expression of conditional-expression
    Given a target source named "fixture.c" with:
      """
      static int foo(int i)
      {
          return i++ > 0 ? i : 0; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W0501 | 3    | 20     |
      | W0628 | 1    | 12     |
