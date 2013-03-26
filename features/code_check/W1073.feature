Feature: W1073

  W1073 detects that a return value of the function is discarded.

  Scenario: simply discarding a return value
    Given a target source named "fixture.c" with:
      """
      extern int bar(void);
      static void foo(void)
      {
          bar(); /* W1073 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1076 | 2    | 13     |
      | W1073 | 4    | 8      |
      | W0629 | 2    | 13     |
      | W0628 | 2    | 13     |

  Scenario: calling `void' function
    Given a target source named "fixture.c" with:
      """
      extern void bar(void);
      static void foo(void)
      {
          bar(); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W1076 | 2    | 13     |
      | W0629 | 2    | 13     |
      | W0628 | 2    | 13     |

  Scenario: discarding return value in comma separated expression
    Given a target source named "fixture.c" with:
      """
      extern int bar(void);
      extern int baz(void);
      static void foo(void)
      {
          int i;
          i = (bar(), baz()); /* W1073 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0118 | 2    | 12     |
      | W1076 | 3    | 13     |
      | W0100 | 5    | 9      |
      | W1073 | 6    | 13     |
      | W0629 | 3    | 13     |
      | W0447 | 6    | 10     |
      | W0628 | 3    | 13     |

  Scenario: discarding return value in for-statement
    Given a target source named "fixture.c" with:
      """
      extern int bar(void);
      static void foo(void)
      {
          int i;
          int j;
          for (i = 0, bar(); i < 10; i++) { /* W1073 */
              j = bar(); /* OK */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1076 | 2    | 13     |
      | W1073 | 6    | 20     |
      | W0629 | 2    | 13     |
      | W0535 | 6    | 10     |
      | W0628 | 2    | 13     |

  Scenario: no assignment but not discarding the return value
    Given a target source named "fixture.c" with:
      """
      extern int bar(void);
      static void foo(void)
      {
          if (bar() == 0) { /* OK */
              return;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1076 | 2    | 13     |
      | W1071 | 2    | 13     |
      | W0629 | 2    | 13     |
      | W0628 | 2    | 13     |

  Scenario: propagating the return value
    Given a target source named "fixture.c" with:
      """
      extern int bar(void);
      static int foo(void)
      {
          return bar(); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1076 | 2    | 12     |
      | W0629 | 2    | 12     |
      | W0628 | 2    | 12     |

  Scenario: propagating the return value in a conditional-expression
    Given a target source named "fixture.c" with:
      """
      extern int bar(void);
      extern int baz(void);
      static int foo(void)
      {
          return bar() == 0 ? baz() : 0; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W0118 | 2    | 12     |
      | W1076 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0501 | 5    | 23     |
      | W0010 | 5    | 23     |
      | W0086 | 5    | 23     |
      | W0628 | 3    | 12     |

  Scenario: standalone function-call-expression as the controlling expression
            of if-statement
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(void)
      {
          int i = 0;
          if (bar(&i)) { /* OK */
              return i;
          }
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W1071 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0114 | 6    | 5      |
      | W0628 | 3    | 12     |

  Scenario: standalone function-call-expression as the controlling expression
            of if-else-statement
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(void)
      {
          int i = 0;
          if (bar(&i)) { /* OK */
              return i;
          } else {
              return 0;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W1071 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0114 | 6    | 5      |
      | W0628 | 3    | 12     |

  Scenario: standalone function-call-expression as the controlling expression
            of while-statement
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(void)
      {
          int i = 0;
          while (bar(&i)) { /* OK */
              i++;
          }
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0114 | 6    | 5      |
      | W0628 | 3    | 12     |

  Scenario: standalone function-call-expression as the controlling expression
            of do-statement
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(void)
      {
          int i = 0;
          do {
              i++;
          } while (bar(&i)); /* OK */
          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0114 | 6    | 5      |
      | W0628 | 3    | 12     |

  Scenario: standalone function-call-expression as the controlling expression
            of for-statement
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(void)
      {
          int i, j = 0;
          for (i = 0; bar(&i); i++) { /* OK */
              j++;
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0114 | 6    | 5      |
      | W0425 | 5    | 12     |
      | W0628 | 3    | 12     |

  Scenario: standalone function-call-expression as the controlling expression
            of c99-for-statement
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static int foo(void)
      {
          int j = 0;
          for (int i = 0; bar(&i); i++) { /* OK */
              j++;
          }
          return j;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 12     |
      | W0629 | 3    | 12     |
      | W0114 | 6    | 5      |
      | W0628 | 3    | 12     |
