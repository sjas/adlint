Feature: W0483

  W0483 detects that the macro defines only storage-class-specifier and
  type-qualifier.

  Scenario: storage-class-specifier and `const' qualifier
    Given a target source named "fixture.c" with:
      """
      #define CONST_1 static const /* W0483 */
      #define CONST_2 extern const /* W0483 */
      #define CONST_3 auto const /* W0483 */
      #define CONST_4 register const /* W0483 */
      #define CONST_5 typedef const /* W0483 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0483 | 1    | 1      |
      | W0483 | 2    | 1      |
      | W0483 | 3    | 1      |
      | W0483 | 4    | 1      |
      | W0483 | 5    | 1      |

  Scenario: storage-class-specifier and `volatile' qualifier
    Given a target source named "fixture.c" with:
      """
      #define VOL_1 static volatile /* W0483 */
      #define VOL_2 extern volatile /* W0483 */
      #define VOL_3 auto volatile /* W0483 */
      #define VOL_4 register volatile /* W0483 */
      #define VOL_5 typedef volatile /* W0483 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0483 | 1    | 1      |
      | W0483 | 2    | 1      |
      | W0483 | 3    | 1      |
      | W0483 | 4    | 1      |
      | W0483 | 5    | 1      |

  Scenario: storage-class-specifier, `const' qualifier and the others
    Given a target source named "fixture.c" with:
      """
      #define MACRO static const int a /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0479 | 1    | 1      |

  Scenario: storage-class-specifier, `volatile' qualifier and the others
    Given a target source named "fixture.c" with:
      """
      #define MACRO volatile static int a /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0479 | 1    | 1      |
