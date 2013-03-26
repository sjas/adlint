Feature: W0088

  W0088 detects that right-hand-side of the logical-expression in a standalone
  expression-statement has no side-effect.

  Scenario: no side-effect in a standalone expression-statement
    Given a target source named "fixture.c" with:
      """
      static int foo(int n)
      {
          int i = bar();
          (i < n) && (i < 10); /* W0088 */
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0109 | 3    | 13     |
      | W0088 | 4    | 13     |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 20     |
      | W0629 | 1    | 12     |
      | W0085 | 4    | 5      |
      | W0628 | 1    | 12     |

  Scenario: side-effect in a standalone expression-statement
    Given a target source named "fixture.c" with:
      """
      static int foo(int n)
      {
          int i = bar();
          (i < n) && (i++); /* OK */
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0109 | 3    | 13     |
      | W0104 | 1    | 20     |
      | W0629 | 1    | 12     |
      | W0508 | 4    | 13     |
      | W0735 | 4    | 16     |
      | W0512 | 4    | 18     |
      | W0628 | 1    | 12     |

  Scenario: no side-effect in controlling expression of for-statement
    Given a target source named "fixture.c" with:
      """
      static int foo(int n)
      {
          int i, j = 0;
          for (i = 0; (i < n) && (i < 10); i++) { /* OK */
              j++;
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0104 | 1    | 20     |
      | W0629 | 1    | 12     |
      | W0425 | 3    | 12     |
      | W0628 | 1    | 12     |

  Scenario: no side-effect in right-most expression of a standalone
            expression-statement
    Given a target source named "fixture.c" with:
      """
      extern int foo(int);
      extern int bar(int);

      static void baz(int i, int j, int k)
      {
          (i > 0) && foo(i) && bar(j) && k; /* W0088 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0118 | 2    | 12     |
      | W1076 | 4    | 13     |
      | W0088 | 6    | 33     |
      | W0104 | 4    | 21     |
      | W0104 | 4    | 28     |
      | W0104 | 4    | 35     |
      | W0629 | 4    | 13     |
      | W0488 | 6    | 5      |
      | W0508 | 6    | 23     |
      | W0508 | 6    | 13     |
      | W0628 | 4    | 13     |

  Scenario: no side-effect in right-most expression of an assignment-expression
    Given a target source named "fixture.c" with:
      """
      extern int foo(int);
      extern int bar(int);

      static void baz(int i, int j, int k)
      {
          int l = 0;
          l = (i > 0) && foo(i) && bar(j) && k; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0118 | 2    | 12     |
      | W1076 | 4    | 13     |
      | W0104 | 4    | 21     |
      | W0104 | 4    | 28     |
      | W0104 | 4    | 35     |
      | W0629 | 4    | 13     |
      | W0488 | 7    | 5      |
      | W0508 | 7    | 27     |
      | W0508 | 7    | 17     |
      | W0628 | 4    | 13     |

  Scenario: no side-effect in argument expressions of function-call-expression
    Given a target source named "fixture.c" with:
      """
      extern int foo(int);
      extern int bar(int);
      extern void baz(const char *, ...);

      static void qux(int i, int j, int k)
      {
          baz("", (i > 0) && foo(i) && bar(i || j) && k); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0118 | 2    | 12     |
      | W0118 | 3    | 13     |
      | W1076 | 5    | 13     |
      | W0104 | 5    | 21     |
      | W0104 | 5    | 28     |
      | W0104 | 5    | 35     |
      | W0629 | 5    | 13     |
      | W0488 | 7    | 13     |
      | W0947 | 7    | 9      |
      | W0508 | 7    | 31     |
      | W0508 | 7    | 21     |
      | W0628 | 5    | 13     |
