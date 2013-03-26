Feature: W0811

  W0811 detects that token sequence replaced by macro contains `defined'
  operator.

  Scenario: no macro replacement
    Given a target source named "fixture.c" with:
      """
      #if defined(FOO) /* OK */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: expanding a wellformed `defined' operator
    Given a target source named "fixture.c" with:
      """
      #define COND defined(FOO)

      #if COND /* W0811 */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0811 | 3    | 5      |

  Scenario: expanding a wellformed expression contains `defined' operator from
            object-like macro
    Given a target source named "fixture.c" with:
      """
      #define COND defined(FOO) && !defined(BAR)

      #if COND /* W0811 */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0811 | 3    | 5      |

  Scenario: expanding a wellformed `defined' operator from function-like macro
    Given a target source named "fixture.c" with:
      """
      #define COND(id) defined(id)

      #if COND(FOO) /* W0811 */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0811 | 3    | 5      |
      | W0443 | 1    | 1      |

  Scenario: expanding a wellformed expression contains `defined' operator from
            function-like macro
    Given a target source named "fixture.c" with:
      """
      #define COND(id1, id2) defined(id1) && !defined(id2)

      #if COND(FOO, BAR) /* W0811 */
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0811 | 3    | 5      |
      | W0443 | 1    | 1      |
