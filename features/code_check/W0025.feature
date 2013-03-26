Feature: W0025

  W0025 detects that there is redundant #include in a source file.

  Scenario: redundant #include of user header
    Given a target source named "fixture.c" with:
      """
      #include "test.h"
      #include "test2.h"
      #include "test.h" /* W0025 */
      """
    And a target source named "test.h" with:
      """
      """
    And a target source named "test2.h" with:
      """
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0025 | 3    | 1      |
      | W0071 | 1    | 1      |
      | W0071 | 2    | 1      |
      | W0071 | 3    | 1      |

  Scenario: no redundant #include of user header
    Given a target source named "fixture.c" with:
      """
      #include "test.h"
      #include "test2.h" /* OK */
      """
    And a target source named "test.h" with:
      """
      """
    And a target source named "test2.h" with:
      """
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0071 | 1    | 1      |
      | W0071 | 2    | 1      |

  Scenario: redundant #include of system header
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>
      #include <math.h>
      #include <stdio.h> /* W0025 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0025 | 3    | 1      |
      | W0070 | 1    | 1      |
      | W0070 | 2    | 1      |
      | W0070 | 3    | 1      |

  Scenario: no redundant #include of system header
    Given a target source named "fixture.c" with:
      """
      #include <stdio.h>
      #include <math.h> /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0070 | 1    | 1      |
      | W0070 | 2    | 1      |
