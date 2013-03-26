Feature: W0643

  W0643 detects that the last backslash of argument tokens will confuse the `#'
  operator in the function-like macro.

  Scenario: one backslash
    Given a target source named "fixture.c" with:
      """
      #define MACRO(x) #x
      const char *str = MACRO(foo\); /* W0643 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0643 | 2    | 28     |
      | W0117 | 2    | 13     |

  Scenario: two backslashes
    Given a target source named "fixture.c" with:
      """
      #define MACRO(x) #x
      const char *str = MACRO(foo\\); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 2    | 13     |

  Scenario: three backslashes
    Given a target source named "fixture.c" with:
      """
      #define MACRO(x) #x
      const char *str = MACRO(foo\\\); /* W0643 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0643 | 2    | 30     |
      | W0117 | 2    | 13     |

  Scenario: four backslashes
    Given a target source named "fixture.c" with:
      """
      #define MACRO(x) #x
      const char *str = MACRO(foo\\\\); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 2    | 13     |

  Scenario: no backslashes
    Given a target source named "fixture.c" with:
      """
      #define MACRO(x) #x
      const char *str = MACRO(foo); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 2    | 13     |

  Scenario: backslashes middle of argument tokens
    Given a target source named "fixture.c" with:
      """
      #define MACRO(x) #x
      const char *str = MACRO(foo \ bar \\ baz); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 2    | 13     |
