Feature: W0642

  W0642 detects that an expression trys to derive address of the array declared
  as `register'.

  Scenario: register array passed as function parameter
    Given a target source named "fixture.c" with:
      """
      extern void foo(char *);

      static void bar(void)
      {
          register char a[3];
          foo(a); /* W0642 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W1076 | 3    | 13     |
      | W0642 | 6    | 9      |
      | W0100 | 5    | 19     |
      | W0629 | 3    | 13     |
      | W0950 | 5    | 21     |
      | W0628 | 3    | 13     |

  Scenario: register array designated in initializer
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          register char a[3];
          char *p = a; /* W0642 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0642 | 4    | 15     |
      | W0100 | 3    | 19     |
      | W0100 | 4    | 11     |
      | W0629 | 1    | 13     |
      | W0950 | 3    | 21     |
      | W0628 | 1    | 13     |

  Scenario: register array designated in assignment
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          register char a[3];
          char *p;
          p = a; /* W0642 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0642 | 5    | 9      |
      | W0100 | 3    | 19     |
      | W0100 | 4    | 11     |
      | W0629 | 1    | 13     |
      | W0950 | 3    | 21     |
      | W0628 | 1    | 13     |
