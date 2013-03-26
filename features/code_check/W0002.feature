Feature: W0002

  W0002 detects that an old style function-definition is found.

  Scenario: all arguments are type specified
    Given a target source named "fixture.c" with:
      """
      int func(arg1, arg2) /* W0002 */
      int arg1;
      char arg2;
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0031 | 2    | 5      |
      | W0031 | 3    | 6      |
      | W0104 | 2    | 5      |
      | W0104 | 3    | 6      |
      | W0002 | 1    | 5      |
      | W0628 | 1    | 5      |

  Scenario: no arguments are type specified
    Given a target source named "fixture.c" with:
      """
      int func(arg1, arg2) /* W0002 */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0031 | 1    | 10     |
      | W0031 | 1    | 16     |
      | W0104 | 1    | 10     |
      | W0104 | 1    | 16     |
      | W0002 | 1    | 5      |
      | W0458 | 1    | 10     |
      | W0458 | 1    | 16     |
      | W0628 | 1    | 5      |

  Scenario: arguments are partly type specified
    Given a target source named "fixture.c" with:
      """
      int func(arg1, arg2) /* W0002 */
      char arg2;
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0031 | 1    | 10     |
      | W0031 | 2    | 6      |
      | W0104 | 1    | 10     |
      | W0104 | 2    | 6      |
      | W0002 | 1    | 5      |
      | W0458 | 1    | 10     |
      | W0628 | 1    | 5      |
