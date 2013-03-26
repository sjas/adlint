Feature: W0635

  W0635 detects that the argument type is not suitable for the corresponding
  conversion-specifier.

  Scenario: `%s' conversion-specifiers with various arguments
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int main(void)
      {
          const char * const foo = "foo";
          const unsigned char * const bar = "bar";
          signed char *baz = "baz";
          char * const qux = "qux";

          return printf("%s %s %s %s", foo, bar, baz, qux); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W9003 | 7    | 24     |
      | W0100 | 7    | 18     |
      | W0947 | 5    | 30     |
      | W0947 | 6    | 39     |
      | W0947 | 7    | 24     |
      | W0947 | 8    | 24     |
      | W0947 | 10   | 19     |

  Scenario: `%s' conversion-specifiers with bad arguments
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int main(void)
      {
          int foo = 0;
          const int bar = 0;
          const int * const baz = 0;

          return printf("%s %s %s", foo, bar, baz); /* W0635 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0635 | 9    | 19     |
      | W0635 | 9    | 19     |
      | W0635 | 9    | 19     |
      | W0100 | 5    | 9      |
      | W0947 | 9    | 19     |
