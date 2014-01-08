Feature: E0018

  E0018 detects that an extra semicolon appears in the global scope.

  Scenario: extra semicolon after variable declaration
    Given a target source named "fixture.c" with:
      """
      int i;;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0018 | 1    | 7      |
      | W0117 | 1    | 5      |

  Scenario: extra semicolon after variable definition
    Given a target source named "fixture.c" with:
      """
      int i = 1;;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0018 | 1    | 11     |
      | W0117 | 1    | 5      |

  Scenario: extra semicolon before variable declaration
    Given a target source named "fixture.c" with:
      """
      ;int i;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0018 | 1    | 1      |
      | W0117 | 1    | 6      |

  Scenario: extra semicolon before variable definition
    Given a target source named "fixture.c" with:
      """
      ;int i = 1;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0018 | 1    | 1      |
      | W0117 | 1    | 6      |

  Scenario: extra semicolon after function declaration
    Given a target source named "fixture.c" with:
      """
      extern void foo(void);;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0018 | 1    | 23     |
      | W0118 | 1    | 13     |

  Scenario: extra semicolon after function definition
    Given a target source named "fixture.c" with:
      """
      int foo(void)
      {
          return 0;
      };
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0018 | 4    | 2      |
      | W0117 | 1    | 5      |
      | W0628 | 1    | 5      |

  Scenario: extra semicolon before function declaration
    Given a target source named "fixture.c" with:
      """
      ;extern void foo(void);
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0018 | 1    | 1      |
      | W0118 | 1    | 14     |

  Scenario: extra semicolon before function definition
    Given a target source named "fixture.c" with:
      """
      ;int foo(void)
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | E0018 | 1    | 1      |
      | W0117 | 1    | 6      |
      | W0628 | 1    | 6      |
