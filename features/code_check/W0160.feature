Feature: W0160

  W0160 detects that `signed char' value is converted into `unsigned long'
  value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(signed char a)
      {
          unsigned long b = a; /* W0160 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0160 | 3    | 23     |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 22     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(signed char a)
      {
          unsigned long b = (unsigned long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0608 | 3    | 23     |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 22     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(signed char a)
      {
          unsigned long b;
          b = a; /* W0160 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0160 | 4    | 9      |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 22     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(signed char a)
      {
          unsigned long b;
          b = (unsigned long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0608 | 4    | 9      |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 22     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned long);

      void foo(signed char a)
      {
          bar(a); /* W0160 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0160 | 5    | 9      |
      | W0104 | 3    | 22     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned long);

      void foo(signed char a)
      {
          bar((unsigned long) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0608 | 5    | 9      |
      | W0104 | 3    | 22     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned long foo(signed char a)
      {
          return a; /* W0160 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 15     |
      | W0160 | 3    | 12     |
      | W0296 | 3    | 5      |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 15     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned long foo(signed char a)
      {
          return (unsigned long) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 15     |
      | W0608 | 3    | 12     |
      | W0104 | 1    | 31     |
      | W0628 | 1    | 15     |
