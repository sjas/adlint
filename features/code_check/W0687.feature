Feature: W0687

  W0687 detects that #undef directive deletes the `defined' operator.

  Scenario: #undef directive with the `defined' operator
    Given a target source named "fixture.c" with:
      """
      #undef defined /* W0687 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0687 | 1    | 8      |

  Scenario: #undef directive with ordinary macro name
    Given a target source named "fixture.c" with:
      """
      #define MACRO (0)
      #undef MACRO /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
