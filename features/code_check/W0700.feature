Feature: W0700

  W0700 detects that no `return' statements with expression is in the function
  which is implicitly declared to return `int' value.

  Scenario: no `return' statement in the implicitly typed function
    Given a target source named "fixture.c" with:
      """
      extern func(void) /* W0700 */
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 8      |
      | W0697 | 1    | 8      |
      | W0700 | 1    | 8      |
      | W0457 | 1    | 8      |
      | W0628 | 1    | 8      |

  Scenario: a `return' statement without expression in the implicitly typed
            function
    Given a target source named "fixture.c" with:
      """
      extern func(void) /* W0700 */
      {
          return;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 8      |
      | W0700 | 1    | 8      |
      | W0457 | 1    | 8      |
      | W0699 | 3    | 5      |
      | W0628 | 1    | 8      |

  Scenario: a `return' statement with expression in the implicitly typed
            function
    Given a target source named "fixture.c" with:
      """
      extern func(void) /* OK */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 8      |
      | W0457 | 1    | 8      |
      | W0628 | 1    | 8      |
