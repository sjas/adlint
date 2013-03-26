Feature: W0109

  W0703 detects that a function-call is performed before declaring the target
  function.

  Scenario: calling function is not declared
    Given a target source named "fixture.c" with:
      """
      int main(void)
      {
          return foo(); /* W0109 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0109 | 3    | 12     |

  Scenario: calling function is forward declared
    Given a target source named "fixture.c" with:
      """
      extern int foo(void);

      int main(void)
      {
          return foo(); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |

  Scenario: calling function is backward declared
    Given a target source named "fixture.c" with:
      """
      int main(void)
      {
          return foo(); /* W0109 */
      }

      extern int foo(void);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0109 | 3    | 12     |
      | W0118 | 6    | 12     |
