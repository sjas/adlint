Feature: W0477

  W0477 detects that there is unpaired `[]',`()',`{}' in macro definition.

  Scenario: unpaired `[]' in macro
    Given a target source named "fixture.c" with:
      """
      #define BEGIN [ /* W0477 */
      #define END ] /* W0477 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0477 | 1    | 1      |
      | W0477 | 2    | 1      |
      | W0480 | 1    | 1      |
      | W0480 | 2    | 1      |

  Scenario: paired `[]' in macro
    Given a target source named "fixture.c" with:
      """
      #define BEGIN [] /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: unpaired `()' in macro
    Given a target source named "fixture.c" with:
      """
      #define BEGIN ( /* W0477 */
      #define END ) /* W0477 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0477 | 1    | 1      |
      | W0477 | 2    | 1      |
      | W0480 | 1    | 1      |
      | W0480 | 2    | 1      |

  Scenario: paired `()' in macro
    Given a target source named "fixture.c" with:
      """
      #define BEGIN () /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: unpaired `{}' in macro
    Given a target source named "fixture.c" with:
      """
      #define BEGIN { /* W0477 */
      #define END } /* W0477 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0477 | 1    | 1      |
      | W0477 | 2    | 1      |
      | W0480 | 1    | 1      |
      | W0480 | 2    | 1      |

  Scenario: paired `{}' in macro
    Given a target source named "fixture.c" with:
      """
      #define BEGIN {} /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
