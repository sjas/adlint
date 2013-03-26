Feature: W0808

  W0808 detects that it pre-defined macro is re-defined.

  Scenario: pre-defined macro is re-defined
    Given a target source named "fixture.c" with:
      """
      #define __STDC_VERSION__ "1" /* W0808 */
      #define __LINE__ "2" /* W0808 */
      #define __FILE__ "3" /* W0808 */
      #define __DATE__ "4" /* W0808 */
      #define __TIME__ "5" /* W0808 */
      #define __STDC__ "6" /* W0808 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0808 | 1    | 9      |
      | W0808 | 2    | 9      |
      | W0808 | 3    | 9      |
      | W0808 | 4    | 9      |
      | W0808 | 5    | 9      |
      | W0808 | 6    | 9      |

  Scenario: undefine the macro defined by the user
    Given a target source named "fixture.c" with:
      """
      #define LINE !LINE
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
