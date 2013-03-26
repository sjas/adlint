Feature: W0147

  W0147 detects that `unsigned int' value is converted into `int' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          int b = a; /* W0147 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0147 | 3    | 13     |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          int b = (int) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 3    | 13     |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          int b;
          b = a; /* W0147 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0147 | 4    | 9      |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          int b;
          b = (int) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 4    | 9      |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(int);

      void foo(unsigned int a)
      {
          bar(a); /* W0147 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0147 | 5    | 9      |
      | W0104 | 3    | 23     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(int);

      void foo(unsigned int a)
      {
          bar((int) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W1049 | 5    | 9      |
      | W0104 | 3    | 23     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      int foo(unsigned int a)
      {
          return a; /* W0147 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0147 | 3    | 12     |
      | W0283 | 3    | 5      |
      | W0104 | 1    | 22     |
      | W0628 | 1    | 5      |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      int foo(unsigned int a)
      {
          return (int) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W1049 | 3    | 12     |
      | W0104 | 1    | 22     |
      | W0628 | 1    | 5      |
