Feature: W1041

  W1041 detects that a non-standard preprocessing directive is found.

  Scenario: a compiler-specific preprocessing directive
    Given a target source named "fixture.c" with:
      """
      #compiler_specific_extension 1 2.3 "4" /* W1041 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1041 | 1    | 1      |
