Feature: W0610

  W0610 detects that a logical expression makes always true.

  Scenario: comparison of static storage duration variable
    Given a target source named "fixture.c" with:
      """
      struct { char *p; } foo = { NULL };
      int *p = NULL;

      static void bar(void)
      {
          if (p != NULL) { /* OK */
              return;
          }

          if (foo.p != NULL) { /* OK */
              return;
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 21     |
      | W0117 | 2    | 6      |
      | W0492 | 2    | 6      |
      | C0001 | 1    | 16     |
      | W1076 | 4    | 13     |
      | W1071 | 4    | 13     |
      | W0629 | 4    | 13     |
      | W0628 | 4    | 13     |
      | W0589 | 1    | 21     |
      | W0593 | 1    | 21     |
      | W0589 | 2    | 6      |
      | W0593 | 2    | 6      |

  Scenario: no explicit controlling-expression in for-statement
    Given a target source named "fixture.c" with:
      """
      void foo(void)
      {
          int i;
          for (i = 0; ; i++) {
              if (i < 0) { /* W0610 */
                  i++;
              }
              if (i == 3) { /* OK not W0610 */
                  i++;
              }
              if (i == 5) { /* OK */
                  break;
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0610 | 5    | 15     |
      | W0613 | 5    | 15     |
      | W0708 | 9    | 14     |
      | W9001 | 6    | 13     |
      | W0114 | 4    | 5      |
      | W0628 | 1    | 6      |

  Scenario: no explicit controlling-expression in c99-for-statement
    Given a target source named "fixture.c" with:
      """
      void foo(void)
      {
          for (int i = 0; ; i++) {
              if (i < 0) { /* W0610 */
                  i++;
              }
              if (i == 3) { /* OK not W0610 */
                  i++;
              }
              if (i == 5) { /* OK */
                  break;
              }
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0610 | 4    | 15     |
      | W0613 | 4    | 15     |
      | W0708 | 8    | 14     |
      | W9001 | 5    | 13     |
      | W0114 | 3    | 5      |
      | W0628 | 1    | 6      |
