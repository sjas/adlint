Feature: W0806

  W0806 detects that the macro named `defined' is defined.

  Scenario: a macro named `defined' is defined
    Given a target source named "fixture.c" with:
      """
      #define defined !defined /* W0806 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0806 | 1    | 9      |

  Scenario: a macro named `define' is defined
    Given a target source named "fixture.c" with:
      """
      #define define !define /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
