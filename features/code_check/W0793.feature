Feature: W0793

  W0793 detects that an explicit conversion between pointer to variable and
  pointer to function is found.

  Scenario: converting `float *' to function pointer
    Given a target source named "fixture.c" with:
      """
      typedef int (*funptr_t)(void);

      funptr_t foo(float *p)
      {
          return (funptr_t) p; /* W0793 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 10     |
      | W0625 | 1    | 15     |
      | W0793 | 5    | 12     |
      | W0104 | 3    | 21     |
      | W0105 | 3    | 21     |
      | W0628 | 3    | 10     |

  Scenario: converting `double *' to function pointer
    Given a target source named "fixture.c" with:
      """
      typedef int (*funptr_t)(void);

      funptr_t foo(double *p)
      {
          return (funptr_t) p; /* W0793 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 10     |
      | W0625 | 1    | 15     |
      | W0793 | 5    | 12     |
      | W0104 | 3    | 22     |
      | W0105 | 3    | 22     |
      | W0628 | 3    | 10     |

  Scenario: converting `long double *' to function pointer
    Given a target source named "fixture.c" with:
      """
      typedef int (*funptr_t)(void);

      funptr_t foo(long double *p)
      {
          return (funptr_t) p; /* W0793 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 10     |
      | W0625 | 1    | 15     |
      | W0793 | 5    | 12     |
      | W0104 | 3    | 27     |
      | W0105 | 3    | 27     |
      | W0628 | 3    | 10     |

  Scenario: converting function pointer to `float *'
    Given a target source named "fixture.c" with:
      """
      typedef int (*funptr_t)(void);

      float *foo(funptr_t p)
      {
          return (float *) p; /* W0793 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 8      |
      | W0793 | 5    | 12     |
      | W0104 | 3    | 21     |
      | W0628 | 3    | 8      |

  Scenario: converting function pointer to `double *'
    Given a target source named "fixture.c" with:
      """
      typedef int (*funptr_t)(void);

      double *foo(funptr_t p)
      {
          return (double *) p; /* W0793 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 9      |
      | W0793 | 5    | 12     |
      | W0104 | 3    | 22     |
      | W0628 | 3    | 9      |

  Scenario: converting function pointer to `long double *'
    Given a target source named "fixture.c" with:
      """
      typedef int (*funptr_t)(void);

      long double *foo(funptr_t p)
      {
          return (long double *) p; /* W0793 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 14     |
      | W0793 | 5    | 12     |
      | W0104 | 3    | 27     |
      | W0628 | 3    | 14     |

  Scenario: converting `float *' to `int *'
    Given a target source named "fixture.c" with:
      """
      int *foo(float *p)
      {
          return (int *) p; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0104 | 1    | 17     |
      | W0105 | 1    | 17     |
      | W0628 | 1    | 6      |

  Scenario: converting function pointer to `void *'
    Given a target source named "fixture.c" with:
      """
      typedef int (*funptr_t)(void);

      void *foo(funptr_t p)
      {
          return (void *) p; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 7      |
      | W0104 | 3    | 20     |
      | W0628 | 3    | 7      |
