Feature: W0016

  W0016 detects that field-width of the conversion-specifier in `*printf'
  function call is greater than 509.

  Scenario: field-width of `%d' conversion-specifier in `printf' function call
            is greater than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int i)
      {
          return printf("%512d", i); /* W0016 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0016 | 5    | 19     |
      | W0104 | 3    | 13     |
      | W0947 | 5    | 19     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `printf' function call
            is equal to 510
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int i)
      {
          return printf("%510d", i); /* W0016 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0016 | 5    | 19     |
      | W0104 | 3    | 13     |
      | W0947 | 5    | 19     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `printf' function call
            is equal to 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int i)
      {
          return printf("%509d", i); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 13     |
      | W0947 | 5    | 19     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `printf' function call
            is less than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int i)
      {
          return printf("%500d", i); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 13     |
      | W0947 | 5    | 19     |
      | W0628 | 3    | 5      |

  Scenario: no field-width of `%d' conversion-specifier in `printf' function
            call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int i)
      {
          return printf("%d", i); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 13     |
      | W0947 | 5    | 19     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `fprintf' function call
            is greater than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int i)
      {
          return fprintf(stdout, "%512d", i); /* W0016 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0016 | 5    | 28     |
      | W0104 | 3    | 13     |
      | W0947 | 5    | 28     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `fprintf' function call
            is equal to 510
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int i)
      {
          return fprintf(stdout, "%510d", i); /* W0016 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0016 | 5    | 28     |
      | W0104 | 3    | 13     |
      | W0947 | 5    | 28     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `fprintf' function call
            is equal to 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int i)
      {
          return fprintf(stdout, "%509d", i); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 13     |
      | W0947 | 5    | 28     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `fprintf' function call
            is less than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int i)
      {
          return fprintf(stdout, "%500d", i); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 13     |
      | W0947 | 5    | 28     |
      | W0628 | 3    | 5      |

  Scenario: no field-width of `%d' conversion-specifier in `fprintf' function
            call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int i)
      {
          return fprintf(stdout, "%d", i); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 13     |
      | W0947 | 5    | 28     |
      | W0628 | 3    | 5      |
