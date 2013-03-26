Feature: W0460

  W0460 detects that a value of the variable is not possibly initialized.

  Scenario: array element is not possibly initialized
    Given a target source named "fixture.c" with:
      """
      static int foo(void)
      {
          int a[5];

          if (a[1] == 0) { /* W0459 */
              a[0] = 0;
          }

          return a[0]; /* W0460 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0459 | 5    | 14     |
      | W0460 | 9    | 13     |
      | W0629 | 1    | 12     |
      | W0950 | 3    | 11     |
      | W0628 | 1    | 12     |
