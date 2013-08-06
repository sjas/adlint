Feature: W0170

  W0170 detects that `long' value is converted into `unsigned short' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(long a)
      {
          unsigned short b = a; /* W0170 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0170 | 3    | 24     |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 15     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(long a)
      {
          unsigned short b = (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0608 | 3    | 24     |
      | C1000 |      |        |
      | C1006 | 1    | 15     |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 15     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(long a)
      {
          unsigned short b;
          b = a; /* W0170 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0170 | 4    | 9      |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 15     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(long a)
      {
          unsigned short b;
          b = (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0608 | 4    | 9      |
      | C1000 |      |        |
      | C1006 | 1    | 15     |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 15     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned short);

      void foo(long a)
      {
          bar(a); /* W0170 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0170 | 5    | 9      |
      | W0104 | 3    | 15     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned short);

      void foo(long a)
      {
          bar((unsigned short) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0608 | 5    | 9      |
      | C1000 |      |        |
      | C1006 | 3    | 15     |
      | W0104 | 3    | 15     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned short foo(long a)
      {
          return a; /* W0170 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 16     |
      | W0170 | 3    | 12     |
      | W0306 | 3    | 5      |
      | W0104 | 1    | 25     |
      | W0628 | 1    | 16     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned short foo(long a)
      {
          return (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 16     |
      | W0608 | 3    | 12     |
      | C1000 |      |        |
      | C1006 | 1    | 25     |
      | W0104 | 1    | 25     |
      | W0628 | 1    | 16     |
