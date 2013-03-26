Feature: W0026

  W0026 detects that there is redundant #include not in a source file but in a
  translation-unit.

  Scenario: redundant #include of user header
    Given a target source named "fixture.c" with:
      """
      #include "test.h"
      #include "test2.h" /* W0026 */

      void foo(void)
      {
      }
      """
    And a target source named "test.h" with:
      """
      #ifndef INCLUDED_TEST
      #define INCLUDED_TEST

      #include "test2.h"

      #endif
      """
    And a target source named "test2.h" with:

      """
      #ifndef INCLUDED_TEST2
      #define INCLUDED_TEST2

      void foo(void);

      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0026 | 2    | 1      |
      | W0071 | 1    | 1      |
      | W0628 | 4    | 6      |

  Scenario: no redundant #include of user header
    Given a target source named "fixture.c" with:
      """
      #include "test.h" /* OK */

      void foo(void)
      {
      }
      """
    And a target source named "test.h" with:
      """
      #ifndef INCLUDED_TEST
      #define INCLUDED_TEST

      #include "test2.h"

      #endif
      """
    And a target source named "test2.h" with:
      """
      #ifndef INCLUDED_TEST2
      #define INCLUDED_TEST2

      void foo(void);

      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0071 | 1    | 1      |
      | W0628 | 3    | 6      |

  Scenario: redundant #include of system header
    Given a target source named "fixture.c" with:
      """
      #include <test.h>
      #include <test2.h> /* W0026 */

      void foo(void)
      {
      }
      """
    And a target source named "test.h" with:
      """
      #ifndef INCLUDED_TEST
      #define INCLUDED_TEST

      #include <test2.h>

      #endif
      """
    And a target source named "test2.h" with:
      """
      #ifndef INCLUDED_TEST2
      #define INCLUDED_TEST2

      void foo(void);

      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0026 | 2    | 1      |
      | W0070 | 1    | 1      |
      | W0628 | 4    | 6      |

  Scenario: no redundant #include of system header
    Given a target source named "fixture.c" with:
      """
      #include <test.h> /* OK */

      void foo(void)
      {
      }
      """
    And a target source named "test.h" with:
      """
      #ifndef INCLUDED_TEST
      #define INCLUDED_TEST

      #include <test2.h>

      #endif
      """
    And a target source named "test2.h" with:
      """
      #ifndef INCLUDED_TEST2
      #define INCLUDED_TEST2

      void foo(void);

      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0070 | 1    | 1      |
      | W0628 | 3    | 6      |
