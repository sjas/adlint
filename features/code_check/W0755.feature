Feature: W0755

  W0755 detects that `long' value is converted into `int' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(long a)
      {
          int b = a; /* W0755 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0755 | 3    | 13     |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 15     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(long a)
      {
          int b = (int) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 15     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(long a)
      {
          int b;
          b = a; /* W0755 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0755 | 4    | 9      |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 15     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(long a)
      {
          int b;
          b = (int) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 15     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(int);

      void foo(long a)
      {
          bar(a); /* W0755 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0755 | 5    | 9      |
      | W0104 | 3    | 15     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(int);

      void foo(long a)
      {
          bar((int) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 15     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      int foo(long a)
      {
          return a; /* W0755 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0755 | 3    | 12     |
      | W0389 | 3    | 5      |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 5      |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      int foo(long a)
      {
          return (int) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0104 | 1    | 14     |
      | W0628 | 1    | 5      |
