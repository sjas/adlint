Feature: W0104

  W0104 detects that a non-const parameter is never changed in the function.

  Scenario: unchanged non-const parameter
    Given a target source named "fixture.c" with:
      """
      static int func(int i) /* W0104 */
      {
          return i + 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0104 | 1    | 21     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: unchanged prefixed const parameter
    Given a target source named "fixture.c" with:
      """
      static int func(const int i) /* OK */
      {
          return i + 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: unchanged postfixed const parameter
    Given a target source named "fixture.c" with:
      """
      static int func(int const i) /* OK */
      {
          return i + 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: unchanged prefixed const volatile parameter
    Given a target source named "fixture.c" with:
      """
      static int func(const volatile int i) /* OK */
      {
          return i + 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: unchanged prefixed volatile const parameter
    Given a target source named "fixture.c" with:
      """
      static int func(volatile const int i) /* OK */
      {
          return i + 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: unchanged mixfixed const volatile parameter
    Given a target source named "fixture.c" with:
      """
      static int func(const int volatile i) /* OK */
      {
          return i + 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: unchanged mixfixed volatile const parameter
    Given a target source named "fixture.c" with:
      """
      static int func(volatile int const i) /* OK */
      {
          return i + 1;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 12     |
      | W0723 | 3    | 14     |
      | W0629 | 1    | 12     |
      | W0628 | 1    | 12     |
