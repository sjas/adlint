Feature: W0239

  W0239 detects that `float' value is converted into `long long' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(float a)
      {
          long long b = a; /* W0239 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0239 | 3    | 19     |
      | W0100 | 3    | 15     |
      | W0104 | 1    | 16     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(float a)
      {
          long long b = (long long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 15     |
      | W0104 | 1    | 16     |
      | W0834 | 3    | 20     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(float a)
      {
          long long b;
          b = a; /* W0239 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0239 | 4    | 9      |
      | W0100 | 3    | 15     |
      | W0104 | 1    | 16     |
      | W0834 | 3    | 5      |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(float a)
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
      | W0104 | 1    | 16     |
      | W0834 | 3    | 5      |
      | W0834 | 4    | 10     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(long long);

      void foo(float a)
      {
          bar(a); /* W0239 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0239 | 5    | 9      |
      | W0104 | 3    | 16     |
      | W0834 | 1    | 17     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(long long);

      void foo(float a)
      {
          bar((long long) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 16     |
      | W0834 | 1    | 17     |
      | W0834 | 5    | 10     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      long long foo(float a)
      {
          return a; /* W0239 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 11     |
      | W0239 | 3    | 12     |
      | W0375 | 3    | 5      |
      | W0104 | 1    | 21     |
      | W0834 | 1    | 1      |
      | W0628 | 1    | 11     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      long long foo(float a)
      {
          return (long long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 11     |
      | W0104 | 1    | 21     |
      | W0834 | 1    | 1      |
      | W0834 | 3    | 13     |
      | W0628 | 1    | 11     |
