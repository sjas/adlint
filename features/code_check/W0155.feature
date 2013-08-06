Feature: W0155

  W0155 detects that `unsigned long long' value is converted into `long' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long long a)
      {
          long b = a; /* W0155 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0155 | 3    | 14     |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 29     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long long a)
      {
          long b = (long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 29     |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 29     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long long a)
      {
          long b;
          b = a; /* W0155 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0155 | 4    | 9      |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 29     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long long a)
      {
          long b;
          b = (long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 4    | 9      |
      | C1000 |      |        |
      | C1006 | 1    | 29     |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 29     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(long);

      void foo(unsigned long long a)
      {
          bar(a); /* W0155 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0155 | 5    | 9      |
      | W0104 | 3    | 29     |
      | W0834 | 3    | 10     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(long);

      void foo(unsigned long long a)
      {
          bar((long) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W1049 | 5    | 9      |
      | C1000 |      |        |
      | C1006 | 3    | 29     |
      | W0104 | 3    | 29     |
      | W0834 | 3    | 10     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      long foo(unsigned long long a)
      {
          return a; /* W0155 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0155 | 3    | 12     |
      | W0291 | 3    | 5      |
      | W0104 | 1    | 29     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      long foo(unsigned long long a)
      {
          return (long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 3    | 12     |
      | C1000 |      |        |
      | C1006 | 1    | 29     |
      | W0104 | 1    | 29     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |
