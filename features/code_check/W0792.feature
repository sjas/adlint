Feature: W0792

  W0792 detects that an explicit conversion between variable of floating point
  number and pointer to a function is found.

  Scenario: converting `float' to function pointer
    Given a target source named "fixture.c" with:
      """
      int (*foo(const float f))(void)
      {
          return (int (*)(void)) f; /* W0792 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0792 | 3    | 12     |
      | W0628 | 1    | 7      |

  Scenario: converting `double' to function pointer
    Given a target source named "fixture.c" with:
      """
      int (*foo(const double f))(void)
      {
          return (int (*)(void)) f; /* W0792 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0792 | 3    | 12     |
      | W0628 | 1    | 7      |

  Scenario: converting `long double' to function pointer
    Given a target source named "fixture.c" with:
      """
      int (*foo(const long double f))(void)
      {
          return (int (*)(void)) f; /* W0792 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0792 | 3    | 12     |
      | W0628 | 1    | 7      |

  Scenario: converting function pointer to `float'
    Given a target source named "fixture.c" with:
      """
      float foo(int (* const p)(void))
      {
          return (float) p; /* W0792 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0792 | 3    | 12     |
      | W0628 | 1    | 7      |

  Scenario: converting function pointer to `double'
    Given a target source named "fixture.c" with:
      """
      double foo(int (* const p)(void))
      {
          return (double) p; /* W0792 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 8      |
      | W0792 | 3    | 12     |
      | W0628 | 1    | 8      |

  Scenario: converting function pointer to `long double'
    Given a target source named "fixture.c" with:
      """
      long double foo(int (* const p)(void))
      {
          return (long double) p; /* W0792 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 13     |
      | W0792 | 3    | 12     |
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

  Scenario: converting function pointer to `void *'
    Given a target source named "fixture.c" with:
      """
      void *foo(int (* const p)(void))
      {
          return (void *) p; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 7      |
      | W0628 | 1    | 7      |
