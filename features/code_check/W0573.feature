Feature: W0573

  W0573 detects that `-' is included at `[]' scanset.

  Scenario: a `-' in scanset
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[-]", &c); /* W0573 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 27     |
      | W0573 | 6    | 19     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |

  Scenario: a `-' in scanset with other character
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[a-z]", &c); /* W0573 */
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

  Scenario: a `-' in scanset with other character
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[a,b]", &c); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 29     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |

  Scenario: proper scanf
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%c", &c); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 25     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |
