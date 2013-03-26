Feature: W0686

  W0686 detects that the same characters exist in a scanset.

  Scenario: same characters exist in a scanset
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[aa]", &c); /* W0686 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 28     |
      | W0686 | 6    | 19     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |

  Scenario: same characters exist in a scanset
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[111]", &c); /* W0686 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 29     |
      | W0686 | 6    | 19     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |

  Scenario: same characters exist in a scanset
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[ababa]", &c); /* W0686 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 31     |
      | W0686 | 6    | 19     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |

  Scenario: proper character list in a scanset
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          char c;
          int i = scanf("%[abcde]", &c); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W0459 | 6    | 31     |
      | W0100 | 5    | 10     |
      | W0100 | 6    | 9      |
      | W0947 | 6    | 19     |
      | W0628 | 3    | 6      |
