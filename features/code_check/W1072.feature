Feature: W1072

  W1072 detects that a `goto' statement is found.

  Scenario: `goto' statement is found
    Given a target source named "fixture.c" with:
      """
      static int func(int i)
      {
          if (i == 1) {
              goto Label1; /* W1072 */
          }

          goto Label2; /* W1072 */

      Label1:
          i = 10;
      Label2:
          i = 20;

          return i;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0629 | 1    | 12     |
      | W1072 | 4    | 9      |
      | W1072 | 7    | 5      |
      | W0628 | 1    | 12     |
