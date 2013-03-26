Feature: W0685

  W0685 detects that the order of the character which including `-' is not
  correct in the scanset.

  Scenario: bigger lower-case character to smaller one
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[z-a]", &c); /* W0685 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 29     |
      | W0573 | 6    | 19     |
      | W0685 | 6    | 19     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |

  Scenario: bigger number to smaller one
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[9-1]", &c); /* W0685 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 29     |
      | W0573 | 6    | 19     |
      | W0685 | 6    | 19     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |

  Scenario: lower-case character to number
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[a-0]", &c); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 29     |
      | W0573 | 6    | 19     |
      | W0685 | 6    | 19     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |

  Scenario: lower-case character to uppercase one
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[a-A]", &c); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 29     |
      | W0573 | 6    | 19     |
      | W0685 | 6    | 19     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |

  Scenario: proper older
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[a-z]", &c); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 29     |
      | W0573 | 6    | 19     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |
