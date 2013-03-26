Feature: W0695

  W0695 detects that the function named `assert' is called because standard
  `assert' macro is undefined.

  Scenario: undefining `assert' macro and then declaring `assert' function
    Given a target source named "fixture.c" with:
      """
      #undef assert /* W0695 */
      extern void assert(int);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0695 | 1    | 8      |
      | W0118 | 2    | 13     |

  Scenario: undefining `assert' macro in function and then declaring `assert'
            function
    Given a target source named "fixture.c" with:
      """
      extern void foo(void)
      {
      #undef assert
          extern void assert(int);
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0695 | 3    | 8      |
      | W0117 | 1    | 13     |
      | W0118 | 4    | 17     |
      | W0622 | 4    | 17     |
      | W0624 | 3    | 1      |
      | W0628 | 1    | 13     |

  Scenario: calling `assert' macro
    Given a target source named "fixture.c" with:
      """
      #include <assert.h>

      void foo(void)
      {
          assert("should not be reached" == ""); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0085 | 5    | 5      |
      | W0628 | 3    | 6      |

  Scenario: `assert' function declared but calling `assert' macro
    Given a target source named "fixture.c" with:
      """
      extern void assert(int);

      #define assert(expr) ((void *) 0) /* to simulate #include <assert.h> */

      void foo(void)
      {
          assert("should not be reached" == ""); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 3    | 1      |
      | W0118 | 1    | 13     |
      | W0117 | 5    | 6      |
      | W0567 | 7    | 5      |
      | W0085 | 7    | 5      |
      | W0628 | 5    | 6      |
