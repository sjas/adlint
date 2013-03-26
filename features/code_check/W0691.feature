Feature: W0691

  W0691 detects that `##' operator makes invalid preprocessing token.

  Scenario: resulting a decimal-constant `123456'
    Given a target source named "fixture.c" with:
      """
      #define MACRO(a, b) a ## b

      double d = (double) MACRO(123, 456); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 3    | 8      |

  Scenario: resulting a floating-constant `.123'
    Given a target source named "fixture.c" with:
      """
      #define MACRO(a, b) a ## b

      double d = (double) MACRO(., 123); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 3    | 8      |

  Scenario: resulting a floating-constant `3.1415'.
    Given a target source named "fixture.c" with:
      """
      #define MACRO(a, b) a ## b

      double d = (double) MACRO(3., 1415); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 3    | 8      |

  Scenario: resulting a floating-constant `1.23e3'
    Given a target source named "fixture.c" with:
      """
      #define MACRO(a, b) a ## b

      double d = (double) MACRO(1.23, e3); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 3    | 8      |

  Scenario: resulting an expression `-123'
    Given a target source named "fixture.c" with:
      """
      #define MACRO(a, b) a ## b

      double d = (double) MACRO(-, 123); /* W0691 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0691 | 3    | 21     |
      | W0117 | 3    | 8      |

  Scenario: resulting an expression `1 / 23'
    Given a target source named "fixture.c" with:
      """
      #define MACRO(a, b) a ## b

      double d = (double) MACRO(1/, 23); /* W0691 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0691 | 3    | 21     |
      | W0195 | 3    | 21     |
      | W0117 | 3    | 8      |

  Scenario: resulting an expression `1.2 * 3.4'
    Given a target source named "fixture.c" with:
      """
      #define MACRO(a, b) a ## b

      double d = (double) MACRO(1.2*, 3.4); /* W0691 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0691 | 3    | 21     |
      | W0117 | 3    | 8      |
