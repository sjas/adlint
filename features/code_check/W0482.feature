Feature: W0482

  W0482 detects that the macro defines type specifier.

  Scenario: macro defines type specifier.
    Given a target source named "fixture.c" with:
      """
      #define VOID void /* W0482 */
      #define INT int /* W0482 */
      #define LONG long /* W0482 */
      #define FLOAT float /* W0482 */
      #define DOUBLE double /* W0482 */
      #define SHORT short /* W0482 */
      #define CHAR char /* W0482 */
      #define STR struct /* W0482 */
      #define UNI union /* W0482 */
      #define ENUM enum /* W0482 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0482 | 1    | 1      |
      | W0482 | 2    | 1      |
      | W0482 | 3    | 1      |
      | W0482 | 4    | 1      |
      | W0482 | 5    | 1      |
      | W0482 | 6    | 1      |
      | W0482 | 7    | 1      |
      | W0482 | 8    | 1      |
      | W0482 | 9    | 1      |
      | W0482 | 10   | 1      |

  Scenario: macro defines signed specifier
    Given a target source named "fixture.c" with:
      """
      #define SIGNED signed /* W0482 */
      #define UNSIGNED unsigned /* W0482 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0482 | 1    | 1      |
      | W0482 | 2    | 1      |

  Scenario: macro defines type specifier and a value
    Given a target source named "fixture.c" with:
      """
      #define UINT unisgned int 10 /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |

  Scenario: macro defines a struct
    Given a target source named "fixture.c" with:
      """
      #define STR struct{int a; int b} /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0479 | 1    | 1      |
