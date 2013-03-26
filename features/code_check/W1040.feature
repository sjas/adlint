Feature: W1040

  W1040 detects that extra tokens after the preprocessing directive.

  Scenario: extra tokens after #endif directive
    Given a target source named "fixture.c" with:
      """
      #define TEST

      #ifdef TEST
      #if defined(CASE_1)
      int i = 1;
      #elif defined(CASE_2)
      int i = 2;
      #endif CASE /* W1040 */
      #else
      int i = 0;
      #endif TEST /* W1040 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1040 | 8    | 8      |
      | W1040 | 11   | 8      |

  Scenario: extra tokens after #endif directive in an invisible branch
    Given a target source named "fixture.c" with:
      """
      #ifdef TEST
      #if defined(CASE_1)
      int i = 1;
      #elif defined(CASE_2)
      int i = 2;
      #endif CASE /* OK */
      #else
      int i = 0;
      #endif TEST /* W1040 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1040 | 9    | 8      |
      | W0117 | 8    | 5      |

  Scenario: extra tokens after #else directive
    Given a target source named "fixture.c" with:
      """
      #define TEST

      #ifdef TEST
      #if defined(CASE_1)
      int i = 1;
      #elif defined(CASE_2)
      int i = 2;
      #else CASE_X /* W1040 */
      int i = 9;
      #endif
      #else
      int i = 0;
      #endif TEST /* W1040 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1040 | 8    | 7      |
      | W1040 | 13   | 8      |
      | W0117 | 9    | 5      |

  Scenario: extra tokens after #else directive in an invisible branch
    Given a target source named "fixture.c" with:
      """
      #ifdef TEST
      #if defined(CASE_1)
      int i = 1;
      #elif defined(CASE_2)
      int i = 2;
      #else CASE_X /* OK */
      int i = 9;
      #endif
      #else
      int i = 0;
      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 10   | 5      |
