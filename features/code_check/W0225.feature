Feature: W0225

  W0225 detects that `double' value is converted into `unsigned short' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(double a)
      {
          unsigned short b = a; /* W0225 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0225 | 3    | 24     |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 17     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(double a)
      {
          unsigned short b = (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 17     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(double a)
      {
          unsigned short b;
          b = a; /* W0225 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0225 | 4    | 9      |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 17     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(double a)
      {
          unsigned short b;
          b = (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0100 | 3    | 20     |
      | W0104 | 1    | 17     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned short);

      void foo(double a)
      {
          bar(a); /* W0225 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0225 | 5    | 9      |
      | W0104 | 3    | 17     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(unsigned short);

      void foo(double a)
      {
          bar((unsigned short) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0104 | 3    | 17     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned short foo(double a)
      {
          return a; /* W0225 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 16     |
      | W0225 | 3    | 12     |
      | W0361 | 3    | 5      |
      | W0104 | 1    | 27     |
      | W0628 | 1    | 16     |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      unsigned short foo(double a)
      {
          return (unsigned short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 16     |
      | W0104 | 1    | 27     |
      | W0628 | 1    | 16     |
