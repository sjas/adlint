Feature: W0756

  W0756 detects that `unsigned long' value is converted into `unsigned char'
  value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          unsigned char b = a; /* W0756 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0756 | 3    | 23     |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          unsigned char b = (unsigned char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          unsigned char b;
          b = a; /* W0756 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0756 | 4    | 9      |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned long a)
      {
          unsigned char b;
          b = (unsigned char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 19     |
      | W0104 | 1    | 24     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned char);

      void foo(unsigned long a)
      {
          bar(a); /* W0756 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0756 | 5    | 9      |
      | W0104 | 3    | 24     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned char);

      void foo(unsigned long a)
      {
          bar((unsigned char) a); /* OK */
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
      unsigned char foo(unsigned long a)
      {
          return a; /* W0756 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 15     |
      | W0756 | 3    | 12     |
      | W0390 | 3    | 5      |
      | W0104 | 1    | 33     |
      | W0628 | 1    | 15     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned char foo(unsigned long a)
      {
          return (unsigned char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 15     |
      | W0104 | 1    | 33     |
      | W0628 | 1    | 15     |
