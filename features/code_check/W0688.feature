Feature: W0688

  W0688 detects that the line number of #line directive is less than 1 or
  greater than 32767.

  Scenario: zero as the line number
    Given a target source named "fixture.c" with:
      """
      #line 0 "test.c" /* W0688 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0688 | 1    | 7      |

  Scenario: valid min line number
    Given a target source named "fixture.c" with:
      """
      #line 1 "test.c" /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: valid line number
    Given a target source named "fixture.c" with:
      """
      #line 1024 "test.c" /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: valid max line number
    Given a target source named "fixture.c" with:
      """
      #line 32767 "test.c" /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: 32768 as the line number
    Given a target source named "fixture.c" with:
      """
      #line 32768 "test.c" /* W0688 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0688 | 1    | 7      |

  Scenario: too big as the line number
    Given a target source named "fixture.c" with:
      """
      #line 4294967296 "test.c" /* W0688 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0688 | 1    | 7      |
