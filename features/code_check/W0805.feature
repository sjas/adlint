Feature: W0805

  W0805 detects that no identifier as argument for the `defined' operator.

  Scenario: no arguments
    Given a target source named "fixture.c" with:
      """
      #if defined /* OK */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0007 | 1    |        |
      | W0804 | 1    | 5      |

  Scenario: an argument specified but not an identifier
    Given a target source named "fixture.c" with:
      """
      #if defined "foo" /* W0805 */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0007 | 1    | 13     |
      | W0804 | 1    | 5      |
      | W0805 | 1    | 5      |

  Scenario: an identifier specified
    Given a target source named "fixture.c" with:
      """
      #if defined FOO /* OK */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: an identifier specified in parenthesis
    Given a target source named "fixture.c" with:
      """
      #if defined(FOO) /* OK */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: no arguments for latter `defined' operator
    Given a target source named "fixture.c" with:
      """
      #if defined(FOO) && defined /* OK */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0007 | 1    |        |
      | W0804 | 1    | 21     |

  Scenario: non identifier for latter `defined' operator
    Given a target source named "fixture.c" with:
      """
      #if defined(FOO) && defined "foo" /* W0805 */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0007 | 1    | 29     |
      | W0804 | 1    | 21     |
      | W0805 | 1    | 21     |

  Scenario: identifiers for two `defined' operator
    Given a target source named "fixture.c" with:
      """
      #if defined(FOO) && defined BAR /* OK */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
