Feature: W0205

  W0205 detects that `unsigned long' value is converted into `long double'
  value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          long double b = a; /* W0205 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0205 | 3    | 21     |
      | W0100 | 3    | 17     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          long double b = (long double) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 17     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          long double b;
          b = a; /* W0205 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0205 | 4    | 9      |
      | W0100 | 3    | 17     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          long double b;
          b = (long double) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 17     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(long double);

      void foo(unsigned long a)
      {
          bar(a); /* W0205 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0205 | 5    | 9      |
      | W0104 | 3    | 24     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(long double);

      void foo(unsigned long a)
      {
          bar((long double) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 24     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      long double foo(unsigned long a)
      {
          return a; /* W0205 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0205 | 3    | 12     |
      | W0341 | 3    | 5      |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 13     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      long double foo(unsigned long a)
      {
          return (long double) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 13     |
