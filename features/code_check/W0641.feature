Feature: W0641

  W0641 detects that an explicit conversion between variable of floating point
  number and pointer to a variable is found.

  Scenario: converting `float' into pointer to `int' variable
    Given a target source named "fixture.c" with:
      """
      int *foo(const float f)
      {
          return (int *) f; /* W0641 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0641 | 3    | 12     |
      | W0628 | 1    | 6      |

  Scenario: converting `double' into pointer to `int' variable
    Given a target source named "fixture.c" with:
      """
      int *foo(const double f)
      {
          return (int *) f; /* W0641 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0641 | 3    | 12     |
      | W0628 | 1    | 6      |

  Scenario: converting `long double' into pointer to `int' variable
    Given a target source named "fixture.c" with:
      """
      int *foo(const long double f)
      {
          return (int *) f; /* W0641 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0641 | 3    | 12     |
      | W0628 | 1    | 6      |

  Scenario: converting `int' into pointer to `float' variable
    Given a target source named "fixture.c" with:
      """
      float foo(int *p)
      {
          return (float) p; /* W0641 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0641 | 3    | 12     |
      | W0104 | 1    | 16     |
      | W0105 | 1    | 16     |
      | W0628 | 1    | 7      |

  Scenario: converting `int' into pointer to `double' variable
    Given a target source named "fixture.c" with:
      """
      double foo(int *p)
      {
          return (double) p; /* W0641 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 8      |
      | W0641 | 3    | 12     |
      | W0104 | 1    | 17     |
      | W0105 | 1    | 17     |
      | W0628 | 1    | 8      |

  Scenario: converting `int' into pointer to `long double'
    Given a target source named "fixture.c" with:
      """
      long double foo(int *p)
      {
          return (long double) p; /* W0641 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0641 | 3    | 12     |
      | W0104 | 1    | 22     |
      | W0105 | 1    | 22     |
      | W0628 | 1    | 13     |

  Scenario: converting `float' to `int'
    Given a target source named "fixture.c" with:
      """
      int foo(const float f)
      {
          return (int) f; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0628 | 1    | 5      |

  Scenario: converting `float' into pointer to `void *'
    Given a target source named "fixture.c" with:
      """
      void *foo(float f)
      {
          return (void *) f; /* W0641 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1   | 7       |
      | W0641 | 3   | 12      |
      | W0104 | 1   | 17      |
      | W0628 | 1   | 7       |
