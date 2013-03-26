Feature: W0017

  W0017 detects that field-width of the conversion-specifier in `*scanf'
  function call is greater than 509.

  Scenario: field-width of `%d' conversion-specifier in `scanf' function call
            is greater than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int *p)
      {
          if (p != NULL) {
              *p = 0;
              return scanf("%512d", p); /* W0017 */
          }
          else {
              return -1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0017 | 7    | 22     |
      | W0104 | 3    | 14     |
      | W1071 | 3    | 5      |
      | W0947 | 7    | 22     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `scanf' function call
            is equal to 510
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int *p)
      {
          if (p != NULL) {
              *p = 0;
              return scanf("%510d", p); /* W0017 */
          }
          else {
              return -1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0017 | 7    | 22     |
      | W0104 | 3    | 14     |
      | W1071 | 3    | 5      |
      | W0947 | 7    | 22     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `scanf' function call
            is equal to 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int *p)
      {
          if (p != NULL) {
              *p = 0;
              return scanf("%509d", p); /* OK */
          }
          else {
              return -1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 14     |
      | W1071 | 3    | 5      |
      | W0947 | 7    | 22     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `scanf' function call
            is less than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int *p)
      {
          if (p != NULL) {
              *p = 0;
              return scanf("%500d", p); /* OK */
          }
          else {
              return -1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 14     |
      | W1071 | 3    | 5      |
      | W0947 | 7    | 22     |
      | W0628 | 3    | 5      |

  Scenario: no field-width of `%d' conversion-specifier in `scanf' function
            call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int *p)
      {
          if (p != NULL) {
              *p = 0;
              return scanf("%d", p); /* OK */
          }
          else {
              return -1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 14     |
      | W1071 | 3    | 5      |
      | W0947 | 7    | 22     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `fscanf' function call
            is greater than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int *p)
      {
          if (p != NULL) {
              *p = 0;
              return fscanf(stdin, "%512d", p); /* W0017 */
          }
          else {
              return -1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0017 | 7    | 30     |
      | W0104 | 3    | 14     |
      | W1071 | 3    | 5      |
      | W0947 | 7    | 30     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `fscanf' function call
            is equal to 510
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int *p)
      {
          if (p != NULL) {
              *p = 0;
              return fscanf(stdin, "%510d", p); /* W0017 */
          }
          else {
              return -1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0017 | 7    | 30     |
      | W0104 | 3    | 14     |
      | W1071 | 3    | 5      |
      | W0947 | 7    | 30     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `fscanf' function call
            is equal to 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int *p)
      {
          if (p != NULL) {
              *p = 0;
              return fscanf(stdin, "%509d", p); /* OK */
          }
          else {
              return -1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 14     |
      | W1071 | 3    | 5      |
      | W0947 | 7    | 30     |
      | W0628 | 3    | 5      |

  Scenario: field-width of `%d' conversion-specifier in `fscanf' function call
            is less than 509
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int *p)
      {
          if (p != NULL) {
              *p = 0;
              return fscanf(stdin, "%500d", p); /* OK */
          }
          else {
              return -1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 14     |
      | W1071 | 3    | 5      |
      | W0947 | 7    | 30     |
      | W0628 | 3    | 5      |

  Scenario: no field-width of `%d' conversion-specifier in `fscanf' function
            call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      int foo(int *p)
      {
          if (p != NULL) {
              *p = 0;
              return fscanf(stdin, "%d", p); /* OK */
          }
          else {
              return -1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0104 | 3    | 14     |
      | W1071 | 3    | 5      |
      | W0947 | 7    | 30     |
      | W0628 | 3    | 5      |
