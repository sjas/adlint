Feature: E0013

  E0013 detects that an expression contains statements.

  Scenario: statements in initializer
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          int j = ({ volatile int *p = &i; i - 1; }); /* E0013 */

          if (j == 0) {
              return 0;
          }
          else {
              return foo(j);
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0013 | 3    | 13     |
      | W0117 | 1    | 5      |
      | W0556 | 9    | 19     |
      | W0100 | 3    | 9      |
      | W0031 | 1    | 13     |
      | W0104 | 1    | 13     |
      | W1071 | 1    | 5      |
      | W0555 | 1    | 5      |
      | W0589 | 1    | 5      |
      | W0591 | 1    | 5      |
