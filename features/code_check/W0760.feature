Feature: W0760

  W0760 detects that `long long' value is converted into `short' value.

  Scenario: implicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(long long a)
      {
          short b = a; /* W0760 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0760 | 3    | 15     |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 20     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in initialization
    Given a target source named "fixture.c" with:
      """
      void foo(long long a)
      {
          short b = (short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 3    | 15     |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 20     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(long long a)
      {
          short b;
          b = a; /* W0760 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0760 | 4    | 9      |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 20     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: explicit conversion in assignment
    Given a target source named "fixture.c" with:
      """
      void foo(long long a)
      {
          short b;
          b = (short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W1049 | 4    | 9      |
      | W0100 | 3    | 11     |
      | W0104 | 1    | 20     |
      | W0834 | 1    | 10     |
      | W0628 | 1    | 6      |

  Scenario: implicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(short);

      void foo(long long a)
      {
          bar(a); /* W0760 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W0760 | 5    | 9      |
      | W0104 | 3    | 20     |
      | W0834 | 3    | 10     |
      | W0628 | 3    | 6      |

  Scenario: explicit conversion in function call
    Given a target source named "fixture.c" with:
      """
      extern void bar(short);

      void foo(long long a)
      {
          bar((short) a); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 13     |
      | W0117 | 3    | 6      |
      | W1049 | 5    | 9      |
      | W0104 | 3    | 20     |
      | W0834 | 3    | 10     |
      | W0628 | 3    | 6      |

  Scenario: implicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      short foo(long long a)
      {
          return a; /* W0760 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0760 | 3    | 12     |
      | W0394 | 3    | 5      |
      | W0104 | 1    | 21     |
      | W0834 | 1    | 11     |
      | W0628 | 1    | 7      |

  Scenario: explicit conversion in function return
    Given a target source named "fixture.c" with:
      """
      short foo(long long a)
      {
          return (short) a; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W1049 | 3    | 12     |
      | W0104 | 1    | 21     |
      | W0834 | 1    | 11     |
      | W0628 | 1    | 7      |
