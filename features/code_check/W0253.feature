Feature: W0253

  W0253 detects that `unsigned int' value is converted into `long long' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          long long b = a; /* W0253 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0253 | 3    | 19     |
      | W0100 | 3    | 15     |
      | W0104 | 1    | 23     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          long long b = (long long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 15     |
      | W0104 | 1    | 23     |
      | W0834 | 3    | 20     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          long long b;
          b = a; /* W0253 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0253 | 4    | 9      |
      | W0100 | 3    | 15     |
      | W0104 | 1    | 23     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          long long b;
          b = (long long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 15     |
      | W0104 | 1    | 23     |
      | W0834 | 3    | 5      |
      | W0834 | 4    | 10     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(long long);

      void foo(unsigned int a)
      {
          bar(a); /* W0253 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0253 | 5    | 9      |
      | W0104 | 3    | 23     |
      | W0834 | 1    | 17     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(long long);

      void foo(unsigned int a)
      {
          bar((long long) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 23     |
      | W0834 | 1    | 17     |
      | W0834 | 5    | 10     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      long long foo(unsigned int a)
      {
          return a; /* W0253 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 11     |
      | W0253 | 3    | 12     |
      | W0409 | 3    | 5      |
      | W0104 | 1    | 28     |
      | W0834 | 1    | 1      |
      | W0628 | 1    | 11     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      long long foo(unsigned int a)
      {
          return (long long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 11     |
      | W0104 | 1    | 28     |
      | W0834 | 1    | 1      |
      | W0834 | 3    | 13     |
      | W0628 | 1    | 11     |
