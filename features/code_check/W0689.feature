Feature: W0689

  W0689 detects that the syntax of #line directive is illformed.

  Scenario: line number as an arithmetic-expression and no file name
    Given a target source named "fixture.c" with:
      """
      #line 35 * 100 /* W0689 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0689 | 1    | 10     |

  Scenario: line number as an arithmetic-expression and valid file name
    Given a target source named "fixture.c" with:
      """
      #line 35 * 100 "test.c" /* W0689 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0689 | 1    | 10     |

  Scenario: valid line number and invalid file name
    Given a target source named "fixture.c" with:
      """
      #line 35 L"******.c" /* W0689 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0689 | 1    | 10     |

  Scenario: inverted arguments
    Given a target source named "fixture.c" with:
      """
      #line __FILE__ 35 /* W0689 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0689 | 1    | 16     |
      | W0690 | 1    | 7      |
