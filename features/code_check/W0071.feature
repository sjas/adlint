Feature: W0071

  W0071 detects that contents of a header included by #include "..." directive
  are not referred by other files in a translation-unit.

  Scenario: a typedef in the header and no reference to it
    Given a target source named "fixture.c" with:
      """
      #include "test.h" /* W0071 */

      int bar(void) { return 0; }
      """
    And a target source named "test.h" with:
      """
      #if !defined(TEST_H)
      #define TEST_H

      typedef int foo;

      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0071 | 1    | 1      |
      | W0628 | 3    | 5      |

  Scenario: a typedef in the header and reference to it in other file.
    Given a target source named "fixture.c" with:
      """
      #include "test.h" /* OK */

      foo bar(void) { return 0; }
      """
    And a target source named "test.h" with:
      """
      #if !defined(TEST_H)
      #define TEST_H

      typedef int foo;

      #endif
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0628 | 3    | 5      |
