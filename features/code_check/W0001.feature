Feature: W0001

  W0001 detects that a number of the expression grouping is greater than 32.

  Scenario: deeply grouped in initializer
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          const int a = 10;
          const int b = 20;
          const int c = (((((((((((((((((((((((((((((((((a + b))))))))))))))))))))))))))))))))); /* W0001 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0629 | 1    | 13     |
      | W0001 | 5    | 51     |
      | W0628 | 1    | 13     |

  Scenario: deeply grouped in expression-statement
    Given a target source named "fixture.c" with:
      """
      static void foo(void)
      {
          const int a = 10;
          const int b = 20;
          int c;
          c = (((((((((((((((((((((((((((((((((a + b))))))))))))))))))))))))))))))))); /* W0001 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0100 | 5    | 9      |
      | W0629 | 1    | 13     |
      | W0001 | 6    | 41     |
      | W0628 | 1    | 13     |
