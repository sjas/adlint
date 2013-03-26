Feature: W0018

  W0018 detects that precision of the conversion-specifier in `*printf'
  function call is greater than 509.

  Scenario: precision of `%f' conversion-specifier in `printf' function call is
            greater than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(double d)
      {
          return printf("%.512f", d); /* W0018 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0018 | 5    | 19     |
      | W0104 | 3    | 16     |
      | W0947 | 5    | 19     |
      | W0628 | 3    | 5      |

  Scenario: precision of `%f' conversion-specifier in `printf' function call is
            equal to 510
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(double d)
      {
          return printf("%.510f", d); /* W0018 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0018 | 5    | 19     |
      | W0104 | 3    | 16     |
      | W0947 | 5    | 19     |
      | W0628 | 3    | 5      |

  Scenario: precision of `%f' conversion-specifier in `printf' function call is
            equal to 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(double d)
      {
          return printf("%.509f", d); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 16     |
      | W0947 | 5    | 19     |
      | W0628 | 3    | 5      |

  Scenario: precision of `%f' conversion-specifier in `printf' function call is
            less than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(double d)
      {
          return printf("%.500f", d); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 16     |
      | W0947 | 5    | 19     |
      | W0628 | 3    | 5      |

  Scenario: no precision of `%f' conversion-specifier in `printf' function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(double d)
      {
          return printf("%f", d); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 16     |
      | W0947 | 5    | 19     |
      | W0628 | 3    | 5      |

  Scenario: precision of `%f' conversion-specifier in `fprintf' function call
            is greater than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(double d)
      {
          return fprintf(stdout, "%.512f", d); /* W0018 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0018 | 5    | 28     |
      | W0104 | 3    | 16     |
      | W0947 | 5    | 28     |
      | W0628 | 3    | 5      |

  Scenario: precision of `%f' conversion-specifier in `fprintf' function call
            is equal to 510
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(double d)
      {
          return fprintf(stdout, "%.510f", d); /* W0018 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0018 | 5    | 28     |
      | W0104 | 3    | 16     |
      | W0947 | 5    | 28     |
      | W0628 | 3    | 5      |

  Scenario: precision of `%f' conversion-specifier in `fprintf' function call
            is equal to 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(double d)
      {
          return fprintf(stdout, "%.509f", d); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 16     |
      | W0947 | 5    | 28     |
      | W0628 | 3    | 5      |

  Scenario: precision of `%f' conversion-specifier in `fprintf' function call
            is less than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(double d)
      {
          return fprintf(stdout, "%.500f", d); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 16     |
      | W0947 | 5    | 28     |
      | W0628 | 3    | 5      |

  Scenario: no precision of `%f' conversion-specifier in `fprintf' function
            call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(double d)
      {
          return fprintf(stdout, "%f", d); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 16     |
      | W0947 | 5    | 28     |
      | W0628 | 3    | 5      |
