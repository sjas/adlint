Feature: W0708

  W0708 detects that a controlling variable of for-statement is updated in the
  loop body.

  Scenario: address of the controlling variable is passed to a function in the
            controlling part of for-statement
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static void foo(void)
      {
          int i;
          for (i = 0; (bar(&i)) && (i < 10); ) { /* OK */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 13     |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |

  Scenario: address of the controlling variable is passed to a function in the
            controlling part of for-statement
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static void foo(void)
      {
          int i;
          for (i = 0; (bar(&i)) && (i < 10); i++) { /* OK */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 13     |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |

  Scenario: address of the controlling variable is passed to a function in the
            controlling part of for-statement
    Given a target source named "fixture.c" with:
      """
      static int bar(int *);

      static void foo(void)
      {
          int i;
          for (i = 0; (bar(&i)) && (i < 10); i++) {
              if (i == 5) { i++; } /* W0708 */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 3    | 13     |
      | W0708 | 7    | 24     |
      | W0629 | 3    | 13     |
      | W0628 | 3    | 13     |
