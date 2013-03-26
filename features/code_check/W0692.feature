Feature: W0692

  W0692 detects that no argument is given to a function-like macro.

  Scenario: empty argument to a function-like macro
    Given a target source named "fixture.c" with:
      """
      #define MACRO(a) #a

      const char *s = (char *) MACRO(); /* W0692 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0692 | 3    | 26     |
      | W0117 | 3    | 13     |

  Scenario: enough arguments to a function-like macro
    Given a target source named "fixture.c" with:
      """
      #define MACRO(a) #a

      const char *s = (char *) MACRO(str); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 3    | 13     |

  Scenario: no argument to a function-like macro
    Given a target source named "fixture.c" with:
      """
      #define MACRO() 0

      const int i = MACRO(); /* W0692 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0442 | 1    | 1      |
      | W0117 | 3    | 11     |
