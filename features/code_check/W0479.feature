Feature: W0479

  W0479 detects that the macro can replace with a typedef declaration.

  Scenario: having the two type specifier
    Given a target source named "fixture.c" with:
      """
      #define UINT unsigned int /* W0479 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0479 | 1    | 1      |

  Scenario: having the type specifier and qualifier
    Given a target source named "fixture.c" with:
      """
      #define CINT const int /* W0479 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0479 | 1    | 1      |

  Scenario: having the type specifier and pointer
    Given a target source named "fixture.c" with:
      """
      #define PLONG long * /* W0479 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0479 | 1    | 1      |

  Scenario: having the type specifier, qualifier and pointer
    Given a target source named "fixture.c" with:
      """
      #define V_CLONG  volatile long * const /* W0479 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0479 | 1    | 1      |

  Scenario: having a type specifier
    Given a target source named "fixture.c" with:
      """
      #define INT int /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0482 | 1    | 1      |

  Scenario: having a type qualifier
    Given a target source named "fixture.c" with:
      """
      #define CONST const /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0483 | 1    | 1      |
