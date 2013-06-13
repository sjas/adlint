Feature: W9001

  W9001 detects that the control never reach to a statement.

  Scenario: indefinitive controlling variable narrowing
    Given a target source named "fixture.c" with:
      """
      static void bar(int);

      int main(void)
      {
          int i;
          int j;

          for (i = 0; i < 10; i++) {
              for (j = 0; j < 10; j++) {
                  if (i == j) {
                      bar(1);
                  }
                  else {
                      bar(2); /* W9001 should not be output */
                  }
              }
          }

          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: indefinitive controlling variable narrowing
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          if (i > 0) {
              do {
                  puts("foo"); /* OK not W9001 */
              } while (i == -1);
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0109 | 5    | 13     |
      | W0610 | 6    | 20     |
      | W0614 | 6    | 20     |
      | W0104 | 1    | 14     |
      | W1073 | 5    | 17     |
      | W0947 | 5    | 18     |
      | W0628 | 1    | 6      |
