Feature: W0207

  W0207 detects that `long long' value is converted into `double' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(long long a)
      {
          double b = a; /* W0207 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0207 | 3    | 16     |
      | W0100 | 3    | 12     |
      | W0104 | 1    | 20     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(long long a)
      {
          double b = (double) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 12     |
      | W0104 | 1    | 20     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(long long a)
      {
          double b;
          b = a; /* W0207 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0207 | 4    | 9      |
      | W0100 | 3    | 12     |
      | W0104 | 1    | 20     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(long long a)
      {
          double b;
          b = (double) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 12     |
      | W0104 | 1    | 20     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(double);

      void foo(long long a)
      {
          bar(a); /* W0207 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0207 | 5    | 9      |
      | W0104 | 3    | 20     |
      | W0834 | 3    | 10     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(double);

      void foo(long long a)
      {
          bar((double) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 20     |
      | W0834 | 3    | 10     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      double foo(long long a)
      {
          return a; /* W0207 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 8      |
      | W0207 | 3    | 12     |
      | W0343 | 3    | 5      |
      | W0104 | 1    | 22     |
      | W0834 | 1    | 12     |
      | W0628 | 1    | 8      |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      double foo(long long a)
      {
          return (double) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 8      |
      | W0104 | 1    | 22     |
      | W0834 | 1    | 12     |
      | W0628 | 1    | 8      |
