Feature: W0690

  W0690 detects that no line number is in the #line directive.

  Scenario: an identifier as arguments
    Given a target source named "fixture.c" with:
      """
      #line LINE1000 /* W0690 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0690 | 1    | 7      |

  Scenario: inverted arguments
    Given a target source named "fixture.c" with:
      """
      #line __FILE__ 35 /* W0690 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0689 | 1    | 16     |
      | W0690 | 1    | 7      |

  Scenario: line number and macro replaceable filename
    Given a target source named "fixture.c" with:
      """
      #line 35 __FILE__ 35 /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
