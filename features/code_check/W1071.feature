Feature: W1071

  W1071 detects that a function has multiple termination points.

  Scenario: explicit returns and implicit return
    Given a target source named "fixture.c" with:
      """
      void foo(int i) /* W1071 */
      {
          if (i == 0) {
              return;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0104 | 1    | 14     |
      | W1071 | 1    | 6      |
      | W0628 | 1    | 6      |

  Scenario: explicit return and no implicit return
    Given a target source named "fixture.c" with:
      """
      void foo(int i) /* OK */
      {
          switch (i) {
          default:
              return;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0104 | 1    | 14     |
      | W0781 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: dead explicit return and implicit return
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int ui) /* OK */
      {
          if (ui < 0U) {
              return; /* dead-code */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0610 | 3    | 12     |
      | W0613 | 3    | 12     |
      | W0104 | 1    | 23     |
      | W9001 | 4    | 9      |
      | W0628 | 1    | 6      |

  Scenario: explicit returns and no implicit return
    Given a target source named "fixture.c" with:
      """
      int foo(int i) /* W1071 */
      {
          if (i == 0) {
              return 0;
          }
          else {
              return 1;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 13     |
      | W1071 | 1    | 5      |
      | W0628 | 1    | 5      |
