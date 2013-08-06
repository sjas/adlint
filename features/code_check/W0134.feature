Feature: W0134

  W0134 detects that `short' value is converted into `char' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(short a)
      {
          char b = a; /* W0134 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0134 | 3    | 14     |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 16     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(short a)
      {
          char b = (char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0608 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 16     |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 16     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(short a)
      {
          char b;
          b = a; /* W0134 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0134 | 4    | 9      |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 16     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(short a)
      {
          char b;
          b = (char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0608 | 4    | 9      |
      | C1000 |      |        |
      | C1006 | 1    | 16     |
      | W0100 | 3    | 10     |
      | W0104 | 1    | 16     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(char);

      void foo(short a)
      {
          bar(a); /* W0134 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0134 | 5    | 9      |
      | W0104 | 3    | 16     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(char);

      void foo(short a)
      {
          bar((char) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0608 | 5    | 9      |
      | C1000 |      |        |
      | C1006 | 3    | 16     |
      | W0104 | 3    | 16     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      char foo(short a)
      {
          return a; /* W0134 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0134 | 3    | 12     |
      | W0270 | 3    | 5      |
      | W0104 | 1    | 16     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      char foo(short a)
      {
          return (char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0608 | 3    | 12     |
      | C1000 |      |        |
      | C1006 | 1    | 16     |
      | W0104 | 1    | 16     |
      | W0628 | 1    | 6      |
