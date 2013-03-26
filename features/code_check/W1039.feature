Feature: W1039

  W1039 detects that an `ll' length-modifier is found in *printf or *scanf
  function call.

  Scenario: an `ll' in printf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(long long ll)
      {
          printf("%lld", ll); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 5    | 12     |
      | W0104 | 3    | 20     |
      | W1073 | 5    | 11     |
      | W0834 | 3    | 10     |
      | W0947 | 5    | 12     |
      | W0628 | 3    | 6      |

  Scenario: an `ll' in scanf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          long long ll = 0;
          scanf("%lld", &ll); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 6    | 11     |
      | W1073 | 6    | 10     |
      | W0834 | 5    | 5      |
      | W0947 | 6    | 11     |
      | W0628 | 3    | 6      |

  Scenario: an `ll' with one of conversion-specifiers in printf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(int i, long long ll, unsigned long ul)
      {
          printf("%d %lld %lu", i, ll, ul); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 5    | 12     |
      | W0104 | 3    | 14     |
      | W0104 | 3    | 27     |
      | W0104 | 3    | 45     |
      | W1073 | 5    | 11     |
      | W0834 | 3    | 17     |
      | W0947 | 5    | 12     |
      | W0628 | 3    | 6      |

  Scenario: an `ll' with one of conversion-specifiers in scanf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          int i = 0;
          long long ll = 0;
          unsigned long ul = 0U;
          scanf("%d %lld %lu", &i, &ll, &ul); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 8    | 11     |
      | W1073 | 8    | 10     |
      | W0834 | 6    | 5      |
      | W0947 | 8    | 11     |
      | W0628 | 3    | 6      |

  Scenario: an `ll' with conversion-specifier `i' in printf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(long long ll)
      {
          printf("%lli", ll); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 5    | 12     |
      | W0104 | 3    | 20     |
      | W1073 | 5    | 11     |
      | W0834 | 3    | 10     |
      | W0947 | 5    | 12     |
      | W0628 | 3    | 6      |

  Scenario: an `ll' with conversion-specifier `o' in printf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(unsigned long long ull)
      {
          printf("%llo", ull); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 5    | 12     |
      | W0104 | 3    | 29     |
      | W1073 | 5    | 11     |
      | W0834 | 3    | 10     |
      | W0947 | 5    | 12     |
      | W0628 | 3    | 6      |

  Scenario: an `ll' with conversion-specifier `u' in printf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(unsigned long long ull)
      {
          printf("%llu", ull); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 5    | 12     |
      | W0104 | 3    | 29     |
      | W1073 | 5    | 11     |
      | W0834 | 3    | 10     |
      | W0947 | 5    | 12     |
      | W0628 | 3    | 6      |

  Scenario: an `ll' with conversion-specifier `x' in printf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(unsigned long long ull)
      {
          printf("%llx", ull); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 5    | 12     |
      | W0104 | 3    | 29     |
      | W1073 | 5    | 11     |
      | W0834 | 3    | 10     |
      | W0947 | 5    | 12     |
      | W0628 | 3    | 6      |

  Scenario: an `ll' with conversion-specifier `X' in printf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(unsigned long long ull)
      {
          printf("%llX", ull); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 5    | 12     |
      | W0104 | 3    | 29     |
      | W1073 | 5    | 11     |
      | W0834 | 3    | 10     |
      | W0947 | 5    | 12     |
      | W0628 | 3    | 6      |

  Scenario: an `ll' with conversion-specifier `d' in fprintf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(long long ll)
      {
          fprintf(stdout, "%lld", ll); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 5    | 21     |
      | W0104 | 3    | 20     |
      | W1073 | 5    | 12     |
      | W0834 | 3    | 10     |
      | W0947 | 5    | 21     |
      | W0628 | 3    | 6      |

  Scenario: multiple `ll' in printf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(long long ll, unsigned long long ull)
      {
          printf("%lld %llu", ll, ull); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 5    | 12     |
      | W1039 | 5    | 12     |
      | W0104 | 3    | 20     |
      | W0104 | 3    | 43     |
      | W1073 | 5    | 11     |
      | W0834 | 3    | 10     |
      | W0834 | 3    | 24     |
      | W0947 | 5    | 12     |
      | W0628 | 3    | 6      |

  Scenario: multiple `ll' in scanf function call
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>

      void foo(void)
      {
          long long ll = 0;
          unsigned long long ull = 0U;
          scanf("%lld %llu", &ll, &ull); /* W1039 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 6      |
      | W1039 | 7    | 11     |
      | W1039 | 7    | 11     |
      | W1073 | 7    | 10     |
      | W0834 | 5    | 5      |
      | W0834 | 6    | 5      |
      | W0947 | 7    | 11     |
      | W0628 | 3    | 6      |
