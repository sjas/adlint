Feature: W0145

  W0145 detects that `unsigned int' value is converted into `signed char'
  value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          signed char b = a; /* W0145 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0145 | 3    | 21     |
      | W0100 | 3    | 17     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          signed char b = (signed char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 3    | 21     |
      | C1000 |      |        |
      | C1006 | 1    | 23     |
      | W0100 | 3    | 17     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          signed char b;
          b = a; /* W0145 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0145 | 4    | 9      |
      | W0100 | 3    | 17     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(unsigned int a)
      {
          signed char b;
          b = (signed char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 4    | 9      |
      | C1000 |      |        |
      | C1006 | 1    | 23     |
      | W0100 | 3    | 17     |
      | W0104 | 1    | 23     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(signed char);

      void foo(unsigned int a)
      {
          bar(a); /* W0145 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0145 | 5    | 9      |
      | W0104 | 3    | 23     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(signed char);

      void foo(unsigned int a)
      {
          bar((signed char) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W1049 | 5    | 9      |
      | C1000 |      |        |
      | C1006 | 3    | 23     |
      | W0104 | 3    | 23     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      signed char foo(unsigned int a)
      {
          return a; /* W0145 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0145 | 3    | 12     |
      | W0281 | 3    | 5      |
      | W0104 | 1    | 30     |
      | W0628 | 1    | 13     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      signed char foo(unsigned int a)
      {
          return (signed char) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W1049 | 3    | 12     |
      | C1000 |      |        |
      | C1006 | 1    | 30     |
      | W0104 | 1    | 30     |
      | W0628 | 1    | 13     |
