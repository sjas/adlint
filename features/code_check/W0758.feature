Feature: W0758

  W0758 detects that `unsigned long' value is converted into `unsigned int'
  value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          unsigned int b = a; /* W0758 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0758 | 3    | 22     |
      | W0100 | 3    | 18     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          unsigned int b = (unsigned int) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 18     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          unsigned int b;
          b = a; /* W0758 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0758 | 4    | 9      |
      | W0100 | 3    | 18     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          unsigned int b;
          b = (unsigned int) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 18     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned int);

      void foo(unsigned long a)
      {
          bar(a); /* W0758 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0758 | 5    | 9      |
      | W0104 | 3    | 24     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned int);

      void foo(unsigned long a)
      {
          bar((unsigned int) a); /* OK */
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
      unsigned int foo(unsigned long a)
      {
          return a; /* W0758 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0758 | 3    | 12     |
      | W0392 | 3    | 5      |
      | W0104 | 1    | 32     |
      | W0628 | 1    | 14     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned int foo(unsigned long a)
      {
          return (unsigned int) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 14     |
      | W0104 | 1    | 32     |
      | W0628 | 1    | 14     |
