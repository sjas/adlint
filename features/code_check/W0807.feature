Feature: W0807

  W0807 detects that it undefined the macro defined as pre-defined.

  Scenario: undefine the macro defined as pre-defined
    Given a target source named "fixture.c" with:
      """
      #undef __STDC_VERSION__ /* W0807 */
      #undef __LINE__ /* W0807 */
      #undef __FILE__ /* W0807 */
      #undef __DATE__ /* W0807 */
      #undef __TIME__ /* W0807 */
      #undef __STDC__ /* W0807 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0807 | 1    | 8      |
      | W0807 | 2    | 8      |
      | W0807 | 3    | 8      |
      | W0807 | 4    | 8      |
      | W0807 | 5    | 8      |
      | W0807 | 6    | 8      |

  Scenario: undefine the macro defined by the user
    Given a target source named "fixture.c" with:
      """
      #define LINE !LINE
      #undef LINE
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
