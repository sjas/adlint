Feature: W0694

  W0694 detects that the function named `assert' is called because standard
  `assert' macro is undefined.

  Scenario: undefining `assert' macro and then declaring `assert' function
    Given a target source named "fixture.c" with:
      """
      #undef assert
      extern void assert(int);

      void foo(void)
      {
          assert("should not be reached" == ""); /* W0694 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0695 | 1    | 8      |
      | W0118 | 2    | 13     |
      | W0117 | 4    | 6      |
      | W0027 | 6    | 36     |
      | W0610 | 6    | 36     |
      | W0694 | 6    | 11     |
      | W0947 | 6    | 12     |
      | W0947 | 6    | 39     |
      | W0628 | 4    | 6      |

  Scenario: declaring `assert' function and then undefining `assert' macro
    Given a target source named "fixture.c" with:
      """
      extern void assert(int);
      #undef assert

      void foo(void)
      {
          assert("should not be reached" == ""); /* W0694 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0695 | 2    | 8      |
      | W0118 | 1    | 13     |
      | W0117 | 4    | 6      |
      | W0027 | 6    | 36     |
      | W0610 | 6    | 36     |
      | W0694 | 6    | 11     |
      | W0947 | 6    | 12     |
      | W0947 | 6    | 39     |
      | W0628 | 4    | 6      |

  Scenario: undefining `assert' macro in function and then declaring `assert'
            function
    Given a target source named "fixture.c" with:
      """
      void foo(void)
      {
      #undef assert
          extern void assert(int);
          assert("should not be reached" == ""); /* W0694 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0695 | 3    | 8      |
      | W0117 | 1    | 6      |
      | W0118 | 4    | 17     |
      | W0622 | 4    | 17     |
      | W0027 | 5    | 36     |
      | W0610 | 5    | 36     |
      | W0694 | 5    | 11     |
      | W0624 | 3    | 1      |
      | W0947 | 5    | 12     |
      | W0947 | 5    | 39     |
      | W0628 | 1    | 6      |

  Scenario: declaring `assert' function and then undefining `assert' macro in
            function
    Given a target source named "fixture.c" with:
      """
      extern void assert(int);

      void foo(void)
      {
      #undef assert
          assert("should not be reached" == ""); /* W0694 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0695 | 5    | 8      |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0027 | 6    | 36     |
      | W0610 | 6    | 36     |
      | W0694 | 6    | 11     |
      | W0624 | 5    | 1      |
      | W0947 | 6    | 12     |
      | W0947 | 6    | 39     |
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
