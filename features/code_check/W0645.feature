Feature: W0645

  W0645 detects that a function parameter is typed as `void'.

  Scenario: a `void' parameter of a `void' function
    Given a target source named "fixture.c" with:
      """
      extern void func(a) /* W0645 */
      void a;
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0031 | 2    | 6      |
      | W0104 | 2    | 6      |
      | W0002 | 1    | 13     |
      | W0645 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: a `void' parameter of a `int' function
    Given a target source named "fixture.c" with:
      """
      extern int func(a) /* W0645 */
      void a;
      {
          return 0;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 12     |
      | W0031 | 2    | 6      |
      | W0104 | 2    | 6      |
      | W0002 | 1    | 12     |
      | W0645 | 1    | 12     |
      | W0628 | 1    | 12     |

  Scenario: multiple parameters including `void' typed one
    Given a target source named "fixture.c" with:
      """
      extern void func(a, b) /* W0645 */
      int a;
      void b;
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0031 | 2    | 5      |
      | W0031 | 3    | 6      |
      | W0104 | 2    | 5      |
      | W0104 | 3    | 6      |
      | W0002 | 1    | 13     |
      | W0645 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: a `void *' parameter
    Given a target source named "fixture.c" with:
      """
      extern void func(p) /* OK */
      void* p;
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0031 | 2    | 7      |
      | W0104 | 2    | 7      |
      | W0105 | 2    | 7      |
      | W0002 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: an `int' parameter
    Given a target source named "fixture.c" with:
      """
      extern void func(a) /* OK */
      int a;
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0031 | 2    | 5      |
      | W0104 | 2    | 5      |
      | W0002 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: a `void' as a parameter-type-list
    Given a target source named "fixture.c" with:
      """
      extern void func(void); /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |

  Scenario: a qualified `void' parameter
    Given a target source named "fixture.c" with:
      """
      extern void func(a) /* W0645 */
      const void a;
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0031 | 2    | 12     |
      | W0002 | 1    | 13     |
      | W0645 | 1    | 13     |
      | W0628 | 1    | 13     |

  Scenario: a more qualified `void' parameter
    Given a target source named "fixture.c" with:
      """
      extern void func(a) /* W0645 */
      const volatile void a;
      {
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0031 | 2    | 21     |
      | W0002 | 1    | 13     |
      | W0645 | 1    | 13     |
      | W0628 | 1    | 13     |
