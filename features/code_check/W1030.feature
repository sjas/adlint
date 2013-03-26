Feature: W1030

  W1030 detects that label with the same name is used more than two.

  Scenario: same named label is used in twice
    Given a target source named "fixture.c" with:
      """
      extern void func(const int a, const int b)
      {
          if (a == 0) {
              int c = 0;
      RETRY:
              b = 10;
          }

          if (b != 0) {
              goto RETRY;
          }
      RETRY: /* W1030 */
          b = 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0100 | 4    | 13     |
      | W0564 | 10   | 9      |
      | W1072 | 10   | 9      |
      | W1030 | 12   | 1      |
      | W0628 | 1    | 13     |

  Scenario: only one label in a function
    Given a target source named "fixture.c" with:
      """
      extern void func(const int a, const int b)
      {
          if (a == 0) {
              int c = 0;
          }

          if (b != 0) {
              goto RETRY;
          }
      RETRY: /* OK */
          b = 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0100 | 4    | 13     |
      | W1072 | 8    | 9      |
      | W0628 | 1    | 13     |

  Scenario: two different labels in a function
    Given a target source named "fixture.c" with:
      """
      extern void func(const int a, const int b)
      {
          if (a == 0) {
              goto ERROR;
          }

          if (b != 0) {
              goto RETRY;
          }

      ERROR: /* OK */
          b = 0;
      RETRY: /* OK */
          b = 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W1072 | 4    | 9      |
      | W1072 | 8    | 9      |
      | W0628 | 1    | 13     |
