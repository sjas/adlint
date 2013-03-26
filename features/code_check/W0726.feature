Feature: W0726

  W0726 detects that `return' statement is found in qualified void function.

  Scenario: `return' with value statement in const void function
    Given a target source named "fixture.c" with:
      """
      const void func(void) /* W0726 */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W1033 | 1    | 12     |
      | W0726 | 3    | 5      |
      | W0628 | 1    | 12     |

  Scenario: `return' with value statement in volatile void function
    Given a target source named "fixture.c" with:
      """
      volatile void func(void) /* W0726 */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 15     |
      | W1033 | 1    | 15     |
      | W0726 | 3    | 5      |
      | W0628 | 1    | 15     |

  Scenario: `return;' statement in const void function
    Given a target source named "fixture.c" with:
      """
      const void func(void) /* OK */
      {
          return;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W1033 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: `return;' statement in volatile void function
    Given a target source named "fixture.c" with:
      """
      volatile void func(void) /* OK */
      {
          return;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 15     |
      | W1033 | 1    | 15     |
      | W0628 | 1    | 15     |

  Scenario: `return' with value statement in void function
    Given a target source named "fixture.c" with:
      """
      void func(void) /* OK */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0628 | 1    | 6      |

  Scenario: `return' statement in void function
    Given a target source named "fixture.c" with:
      """
      void func(void) /* OK */
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0628 | 1    | 6      |
